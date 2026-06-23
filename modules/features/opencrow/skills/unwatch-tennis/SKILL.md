---
name: unwatch-tennis
description: Remove a change detection watch for an ActiveCommunities page via the changedetection.io instance at change.kulak.us. Use when anyone asks to stop watching, unwatch, remove monitoring, or stop notifications for a URL on a domain ending in activecommunities.com.
---

# Unwatch Tennis

## Step 1: Get the URL

Get the activecommunities.com URL the user wants to stop watching.

If the user did not provide a URL, ask for it. Do not guess which watch to remove.

## Step 2: Remove the Watch

Call the `unwatchtennis` helper from PATH:

```bash
unwatchtennis "<activecommunities.com URL>"
```

The helper lists changedetection.io watches, matches the URL exactly first and then without messy query parameters, and deletes the matching watch.

## Step 3: Confirm

If the helper succeeds, tell the user the watch has been removed. You can include the helper's output when it names the removed watch.

If the helper says no matching watch was found, tell the user that page was not being watched.

If the helper says multiple watches matched, do not remove anything else. Tell the user multiple watches matched and ask for a more specific URL.
