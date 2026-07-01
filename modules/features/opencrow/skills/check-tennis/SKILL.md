---
name: check-tennis
description: Check to see if there's any tennis classes to sign up for today.
---

# Check Tennis

Use the native `agent_browser` tool for browser interaction in this skill.

## Step 1: Check whether ActiveCommunities is already signed in

Open:

```text
https://anc.apm.activecommunities.com/portlandparks/wishlist
```

Wait for the JavaScript-rendered app to settle, then check the page URL and title.

If the URL contains `/wishlist` and the title does **not** say "Sign in", assume the saved list is already available and continue to Step 3.

## Step 2: Sign in only if needed

Open:

```text
https://anc.apm.activecommunities.com/portlandparks/signin
```

Wait for the sign-in page to settle.

Use the saved agent-browser auth entry named `activecommunities` to sign in with the `auth login` subcommand:

```text
agent_browser args: ["auth", "login", "activecommunities"]
```

Wait about 8 seconds after the login attempt, then check the URL. If it still contains `/signin`, tell the user that sign-in failed and stop. If the URL changed, continue.

## Step 3: Navigate to the saved list

Open the wishlist page again and wait for it to load:

```text
https://anc.apm.activecommunities.com/portlandparks/wishlist
```

## Step 4: Search the list

Run this JavaScript on the page with `agent_browser` using `eval --stdin`:

```javascript
(async function() {
  const countdownBtn = document.querySelector('.countdown');
  if (!countdownBtn) return false;

  let card = countdownBtn.closest('.wishlist-card');
  if (!card) return false;

  const nameEl = card.querySelector('[data-qa-id="enhancedWishlist-item-name"]');
  const title = nameEl ? nameEl.textContent.trim() : null;

  const wishIcon = card.querySelector('[data-qa-id="enhancedWishlist-item-wished"] a[aria-label]');
  const wishLabel = wishIcon ? wishIcon.getAttribute('aria-label') : '';
  const activityMatch = wishLabel.match(/Activity number (\d+)/);
  const activityNumber = activityMatch ? activityMatch[1] : null;

  const dtItems = card.querySelectorAll('.wishlist-card__datetime__item');
  let date = null;
  let time = null;
  dtItems.forEach((item, i) => {
    const span = item.querySelector('svg ~ span');
    if (span) {
      const text = span.textContent.trim();
      if (i === 0) date = text;
      if (i === 1) time = text;
    }
  });

  // The wishlist DOM only exposes the public activity *number* (e.g. 1204490),
  // not the internal id used in the detail URL. Resolve it via the same-origin
  // search API so we can link straight to the registration page.
  let link = null;
  if (activityNumber) {
    try {
      const res = await fetch('/portlandparks/rest/activities/list?locale=en-US', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ activity_search_pattern: { activity_keyword: activityNumber } })
      });
      const items = (await res.json())?.body?.activity_items || [];
      const match = items.find(it => String(it.number) === activityNumber) || items[0];
      if (match && match.id) {
        link = 'https://anc.apm.activecommunities.com/portlandparks/activity/search/detail/' + match.id;
      }
    } catch (e) {
      link = null;
    }
  }

  return {
    title,
    activityNumber,
    date,
    time,
    link
  };
})();
```

## Step 5: Respond

If the JavaScript returned an object, say this, using its fields. Use the `link`
field for the URL. If `link` is `null` (the lookup failed), fall back to
`https://anc.apm.activecommunities.com/portlandparks/wishlist`:

```text
Heads up! It's almost time to register for <title> on <date>:

<link>
```

Otherwise, if it returned `false`, say there are no open events.

## Notes

- Always use the native `agent_browser` tool for browser steps — this is a JavaScript-rendered UI.
- The real detail link is built from the internal activity id, which is never in the page's HTML — only the public activity *number* is. Step 4 resolves number → id with a same-origin `fetch` to the `activities/list` search API (no extra auth), so the eval must stay `async`.
- Do not use named sessions, manual browser state flags, or direct `agent-browser` CLI commands for this skill.
- If sign-in is needed, try pressing Enter first to submit; if that fails, try clicking the button.
