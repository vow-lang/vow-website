# CLAUDE.md

This file provides guidance to Claude Code when working with code in this repository.

## Project Overview

This is the website for the Vow programming language, hosted at https://www.vow-lang.com. It is a static single-page site built with [Eleventy (11ty)](https://www.11ty.dev/) and deployed to GitHub Pages via GitHub Actions.

## Commands

```bash
npm run build          # Build site to _site/
npm run serve          # Dev server with live reload (http://localhost:8080)
npx @11ty/eleventy     # Direct 11ty invocation
```

## Architecture

- **Static site generator**: 11ty v3 with Nunjucks templates
- **No CSS frameworks** — plain CSS only
- **No JavaScript** — the site is purely static HTML + CSS
- **Deployment**: GitHub Actions (`.github/workflows/pages.yml`) deploys `_site/` to GitHub Pages on push to `main`
- **Custom domain**: `www.vow-lang.com` via `src/CNAME`

## File Structure

```
.eleventy.js              # 11ty config: input=src/, output=_site/, passthrough copies
src/
  index.njk               # Single page content (Nunjucks)
  _includes/
    base.njk              # Base HTML layout (head, meta, favicon, CSS link)
  css/
    style.css             # All styles (dark theme, responsive)
  img/
    v-icon.png            # V logo icon (transparent background, used in header)
    vow-lang.png          # Full logo with name (light background, original)
    vow-lang-dark.png     # Full logo recolored for dark theme
    favicon.png           # Browser tab favicon (V icon)
  CNAME                   # Custom domain for GitHub Pages
.github/workflows/
  pages.yml               # Build + deploy workflow
```

## Design

- **Dark theme**: background `#0d1117`, text `#e6edf3`, accent blue `#58a6ff`, logo orange `#e64b25`
- **Header**: transparent V icon + CSS-rendered wordmark ("vow" in orange, "-lang" in white, "AGENTIC CODING" in muted grey with letter spacing)
- **Responsive**: mobile breakpoint at 640px

## Adding Content

New static assets (images, fonts) go in `src/` and need a `addPassthroughCopy` line in `.eleventy.js` to be copied to `_site/`. Templates in `src/` using `.njk` extension are processed by 11ty automatically.

## Relationship to Main Repo

The Vow compiler and language live in [vow-lang/vow](https://github.com/vow-lang/vow). This repo is website-only. Content about Vow features should stay consistent with the canonical spec in `vow/docs/skill/`.
