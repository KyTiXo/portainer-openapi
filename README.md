![Portainer OpenAPI, bundled Portainer API specs for AI agents and Executor](./.github/assets/readme-banner.png)

<p align="center"><b><a href="https://kytixo.github.io/portainer-openapi/index.json">Index</a></b> · <a href="https://github.com/KyTiXo/portainer-openapi/actions/workflows/pages.yml">Builds</a> · <a href="https://api-docs.portainer.io">Upstream docs</a></p>

**Unofficial, Executor-ready Portainer OpenAPI specs for AI agents.** Every Portainer CE and EE version, bundled into one self-contained JSON file each, rebuilt daily and served from GitHub Pages. Paste a URL into [Executor](https://github.com/UsefulSoftwareCo/executor) and your agent gets the whole Portainer API as typed tools.

## Quick start

One file per edition and version:

```
https://kytixo.github.io/portainer-openapi/<ce|ee>/<version>.json
https://kytixo.github.io/portainer-openapi/ee/2.45.2.json
https://kytixo.github.io/portainer-openapi/index.json     # every available file
```

In Executor:

1. **Add OpenAPI → URL**, paste the spec URL matching your Portainer edition and version.
2. **Base URL**: `https://<your-portainer>/api`
3. **Auth**: `X-API-KEY` header with a Portainer access token (not `jwt`). Use a dedicated Portainer user.

Tools show up with the full API: 486 for EE 2.45.2, 288 for CE 2.45.2. To move to a new Portainer version, use `openapi.updateSpec` with the new URL.

Executor can also re-serve these as MCP tools (`executor mcp`), so MCP-only clients like Claude Code work too.

## Why use it

Portainer's published spec is split across many files with external `$ref`s. Executor resolves only local `#/` refs, so the raw upstream spec yields **0 tools**. This repo bundles each version with [`@redocly/cli`](https://github.com/Redocly/redocly-cli) into a single file with local refs only. The only other change is an [unofficial marker](#unofficial).

* **Full API, exact version.** Every split-OAS3 version of CE and EE, not a hand-written subset.
* **Zero code to maintain.** `build.sh` is a bundle plus a `jq` check, and CI rebuilds daily. New upstream versions appear on their own. If a run fails, the last good deploy stays live.
* **Writes stay gated.** Executor requires approval for every POST/PUT/PATCH/DELETE on OpenAPI tools. Your key is sent only to your Portainer, never to the spec host.
* **Safe by construction.** The build fails unless each spec has exactly one literal `/api` server and only local refs, so a spec can't point the agent at another host.

### Why not an MCP server?

The official `portainer-mcp` is deprecated and its write tools don't set `destructiveHint`, so Executor wouldn't gate them. OpenAPI covers the full API with approval on every write. The one gap is Portainer's Docker/Kubernetes proxy endpoints, which aren't in the upstream spec.

## Build

```sh
./build.sh site     # needs bun, curl, jq. Writes site/<ce|ee>/<version>.json + site/index.json (~1 min)
```

Swagger 2.0 versions upstream aren't bundled. `.github/workflows/pages.yml` runs the same script daily, on push to `main`, and on demand, then deploys `site/` to GitHub Pages.

## Unofficial

Not affiliated with, endorsed by, or supported by Portainer. Each spec's `info.description` starts with an "Unofficial bundled copy of …" marker. The specs are Portainer's work, distributed under Portainer's zlib licence, modified here only by bundling.

The scripts in this repo are MIT. See [LICENSE](LICENSE).
