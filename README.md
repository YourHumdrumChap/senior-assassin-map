# senior-assassin-map

Static Leaflet map that reads initial data from:

- `login.json` (player logins)
- `map-data.json` (markers)

Because this is a static site (no backend), the browser cannot write changes back to these JSON files. New accounts and markers are saved in the browser via `localStorage`.

## Quick start

- Open `login.html` to log in / create an account.
- After login, it redirects to `War map.html` (map-only page).

Deploy on GitHub Pages (project pages): the map page auto-detects `owner/repo` from the URL.

For local testing (opening the file directly or via a local server), set `defaultRepoOwner` and `defaultRepoName` near the top of `War map.html`.

## Data files

- `login.json`: stores usernames + passwords + optional colors.
- `map-data.json`: stores markers.

Note: `login.json` stores passwords in plain text (simple, not secure). Don’t use real passwords.