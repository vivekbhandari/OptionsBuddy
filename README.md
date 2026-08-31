# OptionsBuddy

OptionsBuddy is a browser-based options strategy helper with:
- sign in / sign up / password reset flow
- saved positions in Supabase
- saved Finnhub API key per user
- live price and option-chain data from Finnhub
- strategy library and portfolio dashboard

## Supabase setup

1. Open your Supabase project.
2. Go to SQL Editor.
3. Run the contents of `supabase-setup.sql`.

This creates:
- `public.profiles`
- `public.positions`
- row-level security policies
- automatic profile creation for new users
- automatic `updated_at` timestamps

## Auth configuration

In Supabase Dashboard:
- Authentication → Providers → Email
- enable Email sign in
- enable Email recovery
- optionally disable or enable email confirmation based on your preference

## App config

Update these constants in `index.html` if needed:

```js
var SUPABASE_URL = 'https://YOUR_PROJECT_REF.supabase.co';
var SUPABASE_ANON_KEY = 'YOUR_ANON_KEY';
```

## Reset-password flow

The app uses Supabase Email Recovery. A user clicks "Forgot password?" and receives a recovery email.
The link should redirect back to the app URL, and the app detects the `type=recovery` flow and asks the user to set a new password.

## Local testing

You can open the file directly in a browser, but live pricing calls need a hosted environment that allows outbound `fetch` requests. GitHub Pages, Netlify, or any normal static host will work.

## Notes

- Some features depend on a valid Finnhub API key.
- Position data is saved to Supabase only when the user is signed in.
- When not signed in, the app uses local browser storage as a fallback.
