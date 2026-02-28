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
- If you get `PGRST205` (schema cache / table not found), go to **Supabase Dashboard → Settings → API → Reload schema cache**, then refresh the page.
- In Supabase Auth settings, disable email confirmations (since the app uses username→email mapping and shouldn’t send real emails).
- If you see “email rate limit exceeded” during registration:
	- Turn off **Confirm email** in Supabase Auth (stops confirmation emails), and/or
	- Configure **Custom SMTP** in Supabase so you control email sending limits.
	- If you already tried many times, wait a bit for the rate limit window to reset.
- Put your Supabase Project URL + anon key into `supabase-config.js`.

## Data model

- Markers are stored in the Supabase table `public.markers`.
- Marker fields include: `title` and optional `description`.
- Realtime subscriptions keep the map updated across devices.

## Teammate logins

Supabase Auth stores passwords securely (hashed) and does not let you read them back.

- This project creates a safe table `public.profiles` that stores `user_id` + `username` for each account.
- If you need an “admin list of accounts”, use `public.profiles` (not passwords).