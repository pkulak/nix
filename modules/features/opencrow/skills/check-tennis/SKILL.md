---
name: check-tennis
description: Check to see if there's any tennis classes to sign up for today.
---

# Check Tennis

### Step 1: Make sure we are signed into Active Communities

Navigate the browser to `https://anc.apm.activecommunities.com/portlandparks/signin`. Wait 5 seconds for the page to load.

From the environment, read AC_USERNAME and AC_PASSWORD, and use those to fill out the signin form.

Click the "Sign In" button. Wait 3 seconds.

### Step 2: Navigate to the saved list

Navigate the browser to `https://anc.apm.activecommunities.com/portlandparks/wishlist`. Wait 5 seconds for the page to load.

### Step 3: Search the list

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
- Always use the browser tool for all steps — this is a JavaScript-rendered UI
