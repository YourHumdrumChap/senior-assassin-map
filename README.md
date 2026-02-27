# senior-assassin-map

Static Leaflet map that stores markers in `map-data.json` via the GitHub Contents API.

## Quick start

- Open `login.html` to log in / create an account.
- After login, it redirects to `War map.html` (map-only page).

Deploy on GitHub Pages (project pages): the map page auto-detects `owner/repo` from the URL.

For local testing (opening the file directly or via a local server), set `defaultRepoOwner` and `defaultRepoName` near the top of `War map.html`.

## Marker storage

Markers are stored locally in your browser via `localStorage` (per device/browser).