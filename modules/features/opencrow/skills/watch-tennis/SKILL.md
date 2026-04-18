---
name: watch-tennis
description: Add a change detection watch for an ActiveCommunities page via the changedetection.io instance at change.kulak.us. Use when anyone asks to watch, monitor, or be notified of changes to a URL on a domain ending in activecommunities.com. Triggers on phrases like "watch this page", "let me know when there's a spot", "notify me when it opens", or any activecommunities.com URL combined with watch/monitor intent.
---

# Watch Tennis

## Step 1: Gather Information

Navigate to the activecommunities.com URL and wait for it to load.

Run this Javascript snippet, which will return an object with important info:

  (() => {
    const title = document.querySelector('[data-qa-id="activity-detail-general-name"] span').textContent;
    const date = document.querySelector('.listbox-item__content span').textContent;
    const weekday = document.querySelector('.meeting-time__weekays').textContent;
    const timeRange = document.querySelector('.meeting-time__item span:last-child').textContent;

    return { title, date, weekday, timeRange };
  })();

Remember these values for later steps.

## Step 1: Add the URL

Call the following script:

`~/bin/watchtennis.sh "<activecommunities.com URL>" "<title>"`

## Step 2: Confirm

Use those values to tell the user: "Done! I'm now watching <title> on <weekday> <date>, <timeRange>."
