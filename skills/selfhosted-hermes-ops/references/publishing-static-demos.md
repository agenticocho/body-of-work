# Publishing generated artifacts to static hosting

Sharing demo artifacts (a run viewer, a rendered wall, concept pages) by URL, without exposing a
repository's history. Verified on GitHub Pages from a private repo.

## Enable Pages

```
gh api repos/<owner>/<repo>/pages                                   # 404 = not configured
gh api -X POST repos/<owner>/<repo>/pages \
  -f 'source[branch]=main' -f 'source[path]=/docs'                  # enable
```

- **This succeeds on a PRIVATE repo with no plan-upgrade error.** Do not assume a paid plan is required;
  try it and read the response.
- The response carries `html_url` and **`"public": true`** -- a Pages site is **served publicly regardless
  of repository visibility**. Surface that BEFORE enabling: it is the actual disclosure decision, not the
  repo's visibility.
- `build_type: legacy` builds the source branch on push -- no workflow file, no CI minutes.

## Verify the DEPLOYMENT by bytes, not by size

```
curl -sS <site-url>/ | sha256sum
sha256sum docs/index.html
```

**Served digest == repo digest for EVERY published file.** A size match is not a match: a deployment can
serve a stale build and a size check reports it green. Check the build status as well
(`gh api repos/<o>/<r>/pages/builds/latest`), but treat `building` as uninformative rather than as failure
-- it has reported `building` while the site was already serving the new commit.

## The published file is a COPY, so the publish step must prove it

`docs/` holds a copy of an artifact GENERATED at the repo root. A copy that can drift while looking
authoritative is the defect this project keeps meeting, so the publish step **copies AND then re-reads both
files and compares digests, refusing to report success if they differ** -- plus a `--check` mode that
verifies without writing, for a pre-commit or CI run.

- **A source artifact that is MISSING must refuse, never be replaced with an empty or stale file.**
- **Run the FUNCTION gate UPSTREAM of the copy gate** (see `chilly-ocho-verification`): a parse error moves
  no digest, so a digest gate cannot see a page that does not run.
- **Never hand-edit the generated files under the served dir.** Say in the script header, and in the page's
  own footer, which files are authored and which are generated.

## Make each page self-contained

One HTML file per demo, CSS inline, relative links between pages only, **no CDN, no webfont, no runtime
`fetch`.** Measured rather than stylistic: the artifact that publishes cleanly has zero external references
and zero fetch calls, and a page that pulls a stylesheet renders as a broken shell the first time the
network disagrees -- in front of the person you sent it to.

If a page needs data, EMBED the data. A page that loads data at runtime can fail silently for someone else
while working for you.

## State the STATUS on the landing page

A demo shelf that describes work must say what has actually RUN. **A drawing is not a result** -- a concept
page for a thing that has never executed must say so plainly, in a status block, and the same standard
applies to your own landing page rather than only to the artifacts it links. A page that implies otherwise
is the failure, whatever it renders.
