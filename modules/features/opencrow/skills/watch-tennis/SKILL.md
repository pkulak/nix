---
name: watch-tennis
description: Add a change detection watch for an ActiveCommunities page via the changedetection.io instance at change.kulak.us. Use when anyone asks to watch, monitor, or be notified of changes to a URL on a domain ending in activecommunities.com. Triggers on phrases like "watch this page", "let me know when there's a spot", "notify me when it opens", or any activecommunities.com URL combined with watch/monitor intent.
---

# Watch Tennis

Use the native `agent_browser` tool for browser interaction in this skill.

## Step 1: Gather Information

Open the activecommunities.com URL in the browser and wait for the JavaScript-rendered page content to load.

Run this JavaScript on the page with `agent_browser` using `eval --stdin`:

```javascript
(() => {
  const title = document.querySelector('[data-qa-id="activity-detail-general-name"] span').textContent;
  const date = document.querySelector('.listbox-item__content span').textContent;
  const weekday = document.querySelector('.meeting-time__weekays').textContent;
  const timeRange = document.querySelector('.meeting-time__item span:last-child').textContent;

  return { title, date, weekday, timeRange };
})();
```

Remember the returned `title`, `date`, `weekday`, and `timeRange` values for the confirmation.

If the JavaScript fails because expected elements are missing, wait briefly or inspect the page to confirm it has fully loaded before retrying.

## Step 2: Add the URL

Call the `watchtennis` helper from PATH:

```bash
watchtennis "<activecommunities.com URL>" "<title>"
```

## Step 3: Confirm

Use the gathered values to tell the user:

```text
Done! I'm now watching <title> on <weekday> <date>, <timeRange>.
```
