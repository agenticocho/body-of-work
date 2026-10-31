#!/usr/bin/env python3
"""hermes_freeze_sampler.py — record what the Hermes processes are doing, every 15 s.

Written because a freeze is only diagnosable if its shape is captured: a 100%-CPU process with no
answers is a spinning loop, a 0%-CPU process with no answers is a deadlock, a rising thread or RSS
count is a leak, and a slow answer with normal CPU is a downstream stall. Those four need four
different fixes, and after the fact they look identical.

Reads only /proc and a loopback health probe. No ptrace, no signals, no writes outside its log.

Log: ~/.hermes/profiles/chilly/logs/freeze_sampler.log  (one line per sample, plus a STALL marker)
"""
import json
import os
import time
import urllib.request

LOG = os.path.expanduser("~/.hermes/profiles/chilly/logs/freeze_sampler.log")
# the gateway's fixed port, and the desktop's OS-assigned one discovered from the process table
GATEWAY = "http://127.0.0.1:8642/health"
STALL_MS = 3000
# Electron writes a minidump whenever a zygote/renderer/GPU child dies. The count is a second,
# independent signal: it moves on a crash even when the health probe still gets an answer.
CRASHPAD = os.path.expanduser("~/.config/Hermes/Crashpad/pending")
# v2 (2026-10-26): v1 sampled `serve --host 127.0.0.1 --port 0` and called it "the desktop".
# That is the BACKEND. On 2026-10-26 a freeze the operator had to kill produced zero dumps,
# zero STALL lines and `"desk": {}` -- the instrument was watching the wrong layer, so the
# window that stopped painting was never a subject at all. The GUI is every process running
# out of linux-unpacked/ (browser, zygotes, renderer, GPU child); the busiest one by utime
# delta is the one doing work, and the totals show a leak.
APP_MATCH = "linux-unpacked/"
# Chromium's sticky GPU software-fallback record: a box on software rendering freezes for a
# different reason than a box on the GPU, and v1 could not see this file at all.
FALLBACK = os.path.expanduser("~/.config/Hermes/linux-gpu-fallback.json")
STATE = os.path.expanduser("~/.hermes/profiles/chilly/logs/freeze_sampler.state.json")


def crash_state():
    try:
        dumps = [f for f in os.listdir(CRASHPAD) if f.endswith(".dmp")]
    except OSError:
        return {"dumps": None}
    newest = 0
    if dumps:
        newest = max(os.path.getmtime(os.path.join(CRASHPAD, d)) for d in dumps)
    return {"dumps": len(dumps), "newest_age_s": int(time.time() - newest) if newest else None}


def pids(name_fragment):
    out = []
    for d in os.listdir("/proc"):
        if not d.isdigit():
            continue
        try:
            with open("/proc/%s/cmdline" % d, "rb") as f:
                cmd = f.read().replace(b"\0", b" ").decode("utf-8", "replace")
        except OSError:
            continue
        if name_fragment in cmd:
            out.append(int(d))
    return out


def desk_serve_pid():
    """the `serve --host 127.0.0.1 --port 0` backend the desktop launches.

    NOT any such serve: hermes-local-runtime uses the same flags, so matching on the command
    line alone picks the systemd unit and reports the wrong process all night. The desktop's
    backend is the one whose parent is not systemd (its parent is the Electron app).
    """
    for p in pids("serve --host 127.0.0.1 --port 0"):
        try:
            with open("/proc/%d/stat" % p) as f:
                ppid = int(f.read().split()[3])
            with open("/proc/%d/comm" % ppid) as f:
                parent = f.read().strip()
        except (OSError, IndexError, ValueError):
            continue
        if "systemd" not in parent:
            return p
    return None


def stats(pid):
    if not pid:
        return {}
    try:
        with open("/proc/%d/stat" % pid) as f:
            parts = f.read().split()
        with open("/proc/%d/status" % pid) as f:
            st = dict(l.split(":", 1) for l in f if ":" in l)
        return {
            "pid": pid,
            "rss_mb": int(st.get("VmRSS", "0 kB").split()[0]) // 1024,
            "threads": int(st.get("Threads", "0")),
            "state": parts[2],
            "utime": int(parts[13]),
            "stime": int(parts[14]),
        }
    except (OSError, IndexError, ValueError):
        return {"pid": pid, "gone": True}


def probe(url, timeout=3.0):
    t0 = time.time()
    try:
        req = urllib.request.Request(url, headers={"User-Agent": "freeze-sampler"})
        with urllib.request.urlopen(req, timeout=timeout) as r:
            return r.status, int((time.time() - t0) * 1000)
    except Exception as e:
        return type(e).__name__, int((time.time() - t0) * 1000)


def gpu_fallback():
    try:
        with open(FALLBACK) as f:
            return json.load(f)
    except Exception:
        return None


def load_prev():
    try:
        with open(STATE) as f:
            return json.load(f)
    except Exception:
        return {}


def gui_state(prev):
    """The processes that actually paint, with a utime delta so a spin is visible.

    A deadlock shows flat utime and no answers; a spin shows heavy utime and no answers.
    Those are different defects and v1 could not tell them apart because it had no GUI subject.

    `by_type` is the field that names the culprit: on 2026-10-26 the busiest process held
    ~1.00 core for two hours before the window stalled, and "busiest" alone could not say
    whether that was the renderer, the GPU child or a zygote.
    """
    rows = []
    for p in pids(APP_MATCH):
        s = stats(p)
        if s.get("gone"):
            continue
        s["d_utime"] = s["utime"] - ((prev.get(str(p)) or {}).get("utime", s["utime"]))
        try:
            cmd = open("/proc/%d/cmdline" % p, "rb").read().replace(b"\0", b" ").decode("utf-8", "replace")
        except OSError:
            cmd = ""
        if "--type=" in cmd:
            s["type"] = cmd.split("--type=")[1].split()[0]
        else:
            s["type"] = "browser"
        rows.append(s)
    if not rows:
        return {}, {}
    busiest = max(rows, key=lambda r: r["d_utime"])
    summary = dict(busiest)
    summary["procs"] = len(rows)
    summary["total_threads"] = sum(r.get("threads") or 0 for r in rows)
    summary["total_rss_mb"] = sum(r.get("rss_mb") or 0 for r in rows)
    by_type = {}
    for r in rows:
        t = r.get("type") or "?"
        d = r.get("d_utime") or 0
        if d > 0:
            by_type[t] = by_type.get(t, 0) + d
    summary["by_type"] = by_type
    return summary, {str(r["pid"]): {"utime": r["utime"]} for r in rows}


def main():
    os.makedirs(os.path.dirname(LOG), exist_ok=True)
    gw = pids("hermes-gateway") or pids("/hermes-agent")
    gw_pid = gw[0] if gw else None
    dpid = desk_serve_pid()
    code, ms = probe(GATEWAY)
    g = stats(gw_pid)
    d = stats(dpid)
    gui, gui_now = gui_state(load_prev())
    now = time.strftime("%Y-%m-%dT%H:%M:%S")
    line = {
        "t": now, "gw_health": code, "gw_ms": ms,
        "gw": g, "desk": d, "crash": crash_state(),
        "gui": gui, "gpu_fallback": gpu_fallback(),
    }
    stall = (code != 200) or ms > STALL_MS
    with open(LOG, "a") as f:
        f.write(json.dumps(line) + "\n")
        if stall:
            # the marker is deliberately row-shaped differently from a sample so a reader cannot
            # mistake one for the other
            f.write("STALL %s gateway=%s in %d ms gw_pid=%s desk_pid=%s\n"
                    % (now, code, ms, gw_pid, dpid))
    if stall:
        print("STALL gateway=%s %dms" % (code, ms))
    try:
        with open(STATE, "w") as f:
            json.dump(gui_now, f)
    except OSError:
        pass


if __name__ == "__main__":
    main()
