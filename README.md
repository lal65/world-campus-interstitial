# World Campus Interstitial
The **World Campus Interstitial** is the page shown while a managed challenge
verifies a visitor’s browser. It provides the branded Penn State World Campus
experience during that short wait.

## Purpose
This repository exists to build and publish the interstitial page used for
managed challenges. The page includes:

- Penn State World Campus branding
- A browser verification message
- A callout explaining why the page appears
- Contact information and footer links
- Static assets and bundled styles for deployment

## How to use it?
Install the package from GitHub Packages.

### Configure authentication
GitHub Packages requires the `@psu-online-education` scope to be routed to the
GitHub npm registry.

Create a user-level or project-level `.npmrc` file with:

```text
@psu-online-education:registry=https://npm.pkg.github.com
//npm.pkg.github.com/:_authToken=${NODE_AUTH_TOKEN}
```

Then export a GitHub personal access token with at least `read:packages` to the
`NODE_AUTH_TOKEN` environment variable.

```bash
export NODE_AUTH_TOKEN=YOUR_GITHUB_PAT
npm install @psu-online-education/interstitial
```

If you prefer to authenticate interactively, you may also use:

```bash
npm login --scope=@psu-online-education --auth-type=legacy --registry=https://npm.pkg.github.com
npm install @psu-online-education/interstitial
```

### Deploy the built assets
Once the dependency is installed, the static assets can be copied to a web
accessible location and the `index.html` file contents can be loaded into
a Cloudflare error rule. The default build assumes the `/interstitial`
directory will be used. If this default is not agreeable, then custom builds
may also be used.

## Key Constraint: Cloudflare Managed Challenge Limits
The build process is designed around a specific Cloudflare limitation:

- **Cloudflare limits managed challenge DOM sizes to 10kB**
- Because of that, the page content is split into partial HTML files
- Those partials are **gzip-compressed and base64-encoded**
- At runtime, the page decodes and injects them into the DOM with JavaScript

This is why the HTML is assembled dynamically instead of being delivered as one
large static document.

## How It Works
The main entry point is `src/index.html`.

During build, the script:

1. Copies required static assets into `dist/`
2. Builds the CSS bundle
3. Copies HTML partials into `build/`
4. Replaces `::ASSET_PREFIX::` with the requested prefix
5. Gzip-compresses the partials
6. Base64-encodes them
7. Injects them into `src/index.html`

At runtime, the page uses a small script to decode and insert the compressed
HTML fragments into the page.

## Repository Structure
- `.github/workflows/package.yml` — builds and publishes the package on version
  tags
- `.github/workflows/pages.yml` — builds and deploys static content to GitHub
  Pages from `main`
- `build.sh` — build script that assembles the final `dist/` output
- `src/index.html` — main HTML page
- `src/_before_begin_main.html` — HTML inserted before the main content
- `src/_after_begin_main.html` — HTML inserted immediately after the main
  element begins
- `src/_before_end_main.html` — HTML inserted before the main element ends
- `src/_after_end_main.html` — HTML inserted after the main element ends
- `src/overrides.css` — local style overrides
- `src/robots.txt` — robots rules
- `package.json` — package metadata and dependencies
- `package-lock.json` — locked dependency versions

## Prerequisites for Development
To work on this project, you need:

- **Node.js LTS**
- `npm`
- A Unix-like shell environment for running `build.sh`

## Getting Started

### 1. Install dependencies

```bash
npm ci
```

This uses the lockfile for reproducible installations and supply chain security
hardening.

### 2. Build the interstitial

```bash
./build.sh interstitial
```

This generates the final output in `dist/`.

### 3. Build for GitHub Pages

```bash
./build.sh world-campus-interstitial
```

This build uses the repository name as the asset prefix, which is needed for
GitHub Pages.

## Asset Prefixing

The build script accepts an optional prefix argument:

```bash
./build.sh <prefix>
```

The prefix is used to rewrite asset URLs such as:

- `::ASSET_PREFIX::/interstitial.css`
- `::ASSET_PREFIX::/wc-mark.svg`
- `::ASSET_PREFIX::/psu-mark.svg`

This allows the same source to work across different hosting environments.

## Local Development Notes

When editing the page, keep these points in mind:

- The HTML partials are intentionally split up to respect Cloudflare DOM size
  constraints
- Any content added to the page should stay lightweight
- Styles should go through `src/overrides.css` if they are local overrides
- Static assets copied by the build script must remain in `src/`
- Changes to the injected HTML should be made in the matching partial file

## Publishing

### Package Release

The package workflow runs on version tags matching:

```text
[0-9]+.[0-9]+.[0-9]+
```

On tag push, it:

- checks out the repository
- sets up Node.js
- installs dependencies
- runs the build
- publishes the package to GitHub Packages

### GitHub Pages Deployment

The Pages workflow runs on pushes to `main` and:

- installs dependencies
- builds the site with the GitHub Pages prefix
- uploads `dist/`
- deploys to GitHub Pages

## Conventions

- Keep the final DOM small
- Preserve the build-time injection model
- Update partials in `src/` rather than editing generated output
- Use `npm ci` for reproducible installs
- Ensure assets continue to resolve correctly in both package and Pages
  deployments

## Files Generated by the Build

The build process creates:

- `dist/` — published static output
- `build/` — temporary build artifacts used during HTML assembly

These should not be committed.

## Ignored Files

The repository ignores:

- `.idea`
- `node_modules`
- `build`
- `dist`
