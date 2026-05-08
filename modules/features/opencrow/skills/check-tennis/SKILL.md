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

Use the `AC_USERNAME` and `AC_PASSWORD` environment variables to fill the sign-in form. Do not inspect or display their contents.

Try pressing Enter to submit first; this sometimes works better than clicking the button. If Enter does not work, take a fresh interactive snapshot and click the "Sign In" button.

Wait about 8 seconds, then check the URL. If it still contains `/signin`, tell the user that sign-in failed and stop. If the URL changed, continue.

## Step 3: Navigate to the saved list

Open the wishlist page again and wait for it to load:

```text
https://anc.apm.activecommunities.com/portlandparks/wishlist
```

## Step 4: Search the list

Run this JavaScript on the page with `agent_browser` using `eval --stdin`:

```javascript
(function() {
  const countdownBtn = document.querySelector('.countdown');
  if (!countdownBtn) return false;

  let card = countdownBtn.closest('.wishlist-card');
  if (!card) return false;

  const nameEl = card.querySelector('[data-qa-id="enhancedWishlist-item-name"]');
  const title = nameEl ? nameEl.textContent.trim() : null;

  const nameLink = nameEl ? nameEl.querySelector('a') : null;
  const ariaLabel = nameLink ? nameLink.getAttribute('aria-label').trim() : null;

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

  return {
    title,
    ariaLabel,
    activityNumber,
    date,
    time
  };
})();
```

## Step 5: Respond

If the JavaScript returned an object, say this, using its fields:

```text
Heads up! It's almost time to register for <title> on <date>:

https://anc.apm.activecommunities.com/portlandparks/wishlist
```

Otherwise, if it returned `false`, say there are no open events.

## Notes

- Always use the native `agent_browser` tool for browser steps — this is a JavaScript-rendered UI.
- Do not use named sessions, manual browser state flags, or direct `agent-browser` CLI commands for this skill.
- If sign-in is needed, try pressing Enter first to submit; if that fails, try clicking the button.
