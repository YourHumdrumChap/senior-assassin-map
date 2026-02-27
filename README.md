# senior-assassin-map

Static Leaflet map that stores markers in `map-data.json` via the GitHub Contents API.

## Quick start

- Open `login.html` to log in / create an account.
- After login, it redirects to `War map.html` (map-only page).

Deploy on GitHub Pages (project pages): the map page auto-detects `owner/repo` from the URL.

For local testing (opening the file directly or via a local server), set `defaultRepoOwner` and `defaultRepoName` near the top of `War map.html`.

## GitHub token

To add/edit/delete markers you need a GitHub token with permission to update repository contents.

- Prefer a fine-grained PAT scoped to this repo with **Contents: Read and write**.
- Paste it into the map's **GitHub Token** box and click **Save Token**.

## Data file

The marker data lives in `map-data.json` at the repo root.