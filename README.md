# senior-assassin-map

Static Leaflet map hosted on GitHub Pages with shared, live-updating markers powered by Supabase.

## Quick start

- Open `login.html` to log in / create an account.
- After login, it redirects to `War map.html` (map-only page).

Deploy on GitHub Pages (project pages): the map page auto-detects `owner/repo` from the URL.

For local testing (opening the file directly or via a local server), set `defaultRepoOwner` and `defaultRepoName` near the top of `War map.html`.

## Supabase setup

- Create a Supabase project.
- Run the SQL in `supabase_setup.sql` (creates `public.markers` + RLS policies + realtime publication).
- In Supabase Auth settings, consider disabling email confirmations (since the app uses username→email mapping).
- Put your Supabase Project URL + anon key into `supabase-config.js`.

## Data model

- Markers are stored in the Supabase table `public.markers`.
- Realtime subscriptions keep the map updated across devices.