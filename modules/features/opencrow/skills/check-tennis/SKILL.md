---
name: check-tennis
description: Check to see if there's any tennis classes to sign up for today.
---

# Check Tennis

### Step 1: Check for existing session

Navigate the browser to `https://anc.apm.activecommunities.com/portlandparks/wishlist` using the `--profile ~/.activecommunities` flag on `agent-browser open`. Wait 5 seconds.

Check the current URL. If it contains `/wishlist` and the page title does NOT say "Sign in", you are already logged in — skip to Step 3.

### Step 2: Sign in (only if needed)

Navigate to `https://anc.apm.activecommunities.com/portlandparks/signin` (same profile). Wait 5 seconds.

From the environment, read AC_USERNAME and AC_PASSWORD, and use those to fill out the signin form.

**Finding form fields:** Run `agent-browser snapshot` to get the accessibility tree with refs, then use the `@ref` syntax to fill fields (e.g. `agent-browser fill @e10 "user@example.com"`). Do NOT guess CSS selectors — this site's inputs may not match standard selectors.

This site uses reCAPTCHA. Press Enter to submit the form — this sometimes bypasses the CAPTCHA better than clicking the button. If that doesn't work, try clicking the "Sign In" button (using its `@ref` from the snapshot) instead.

Wait 8 seconds, then check the URL. If it still contains `/signin`, the login failed.

If the URL changed (e.g. `/myaccount`), proceed.

### Step 3: Navigate to the saved list

Navigate the browser to `https://anc.apm.activecommunities.com/portlandparks/wishlist` (same profile). Wait 5 seconds for the page to load.

### Step 4: Search the list

Execute the following JavaScript on the page:

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

If it returns an object, say this, using the fields from the object:

    Heads up! It's almost time to register for <title> on <date>:

    https://anc.apm.activecommunities.com/portlandparks/wishlist

Otherwise (it returns false), reply with only HEARTBEAT_OK.

## Notes

- Do not comment on the steps you take as you take them. Respond once, at the end.
- Always use the browser tool for all steps — this is a JavaScript-rendered UI.
- Always use `--profile ~/.activecommunities` on `agent-browser open` to persist the login session across runs.
- Never retry a failed login or take screenshots to debug — just report the failure.
- If sign-in is needed, try pressing Enter first to submit (reCAPTCHA workaround); if that fails, try clicking the button.
