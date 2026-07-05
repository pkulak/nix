---
name: check-tennis
description: Check to see if there's any tennis classes to sign up for today.
---

# Check Tennis

Use the native `agent_browser` tool for browser interaction in this skill.

## Step 1: Load the saved list with one browser batch

ActiveCommunities is fragile if navigation and inspection happen in separate
`agent_browser` calls: the follow-up call can lose the tab and report
`about:blank`, and the JavaScript app can render an empty page for a few
seconds. Always combine open + wait + inspection in one `batch`.

Call:

```text
agent_browser args: ["batch"]
stdin:
[["open", "https://anc.apm.activecommunities.com/portlandparks/wishlist"],
 ["wait", "3000"],
 ["get", "title"],
 ["get", "url"],
 ["snapshot", "-i"]]
```

If the URL contains `/wishlist`, the title does **not** say "Sign in", and the
snapshot shows the wishlist UI, continue to Step 3.

If the URL contains `/signin` or the title says "Sign in", continue to Step 2.

If the URL contains `/wishlist` but the snapshot/body is empty, do **not**
assume sign-in failed. Repeat the same batch with `wait` set to `8000` before
deciding what to do.

## Step 2: Sign in only if needed

Use the saved agent-browser auth entry named `activecommunities` to sign in with
the `auth login` subcommand:

```text
agent_browser args: ["auth", "login", "activecommunities"]
```

Do not inspect the current page immediately after `auth login`, and do not use
separate `open`, `get`, or `snapshot` calls for the next load. Immediately reload
the wishlist with the same batched open + wait + inspection pattern from Step 1.

If `auth login` reports `loggedIn: true` but the batched reload still ends on
`/signin` or a page titled "Sign in", do **not** immediately conclude the saved
auth entry is bad. This can happen when the agent-browser managed session or
background process is stale. Recover once:

```text
agent_browser args: ["close"]
agent_browser args: ["auth", "login", "activecommunities"]
```

Then reload the wishlist with the Step 1 batch using `wait` set to `8000`.

Only if this recovery attempt also ends on `/signin` or a page titled "Sign in"
should you tell the user that the saved auth login failed. If it ends on
`/wishlist` but the page is empty, repeat the batched reload once with an 8
second wait.

## Step 3: Make sure the saved list is ready

Before searching, the current page should be
`https://anc.apm.activecommunities.com/portlandparks/wishlist` and the snapshot
should show the wishlist UI, such as the "Saved for Later List" heading.

If a later browser call reports `about:blank`, rerun the Step 1 batch and retry
the action. Do not re-authenticate unless the batched reload lands on `/signin`.

## Step 4: Search the list

Run the search eval in the same browser `batch` that opens the wishlist. Do not
run `eval --stdin` as a separate `agent_browser` call; crossing browser calls is
where ActiveCommunities most often falls back to `about:blank`.

Call:

```text
agent_browser args: ["batch"]
stdin:
[["open", "https://anc.apm.activecommunities.com/portlandparks/wishlist"],
 ["wait", "3000"],
 ["get", "title"],
 ["get", "url"],
 ["eval", "<paste the JavaScript below as one JSON string; do not send this placeholder literally>"]]
```

Inside a batch, the eval step is `["eval", "..."]` — do **not** use
`["eval", "--stdin"]` there.

Use this JavaScript for the eval step:

```javascript
(async function() {
  if (
    location.hostname !== 'anc.apm.activecommunities.com' ||
    location.pathname !== '/portlandparks/wishlist'
  ) {
    return { error: 'wrong-page', url: location.href, title: document.title };
  }

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

Only trust the eval result if the same batch's `get url` step is on
`/portlandparks/wishlist`, the eval step's origin is also the wishlist page, and
there is no `about:blank` warning.

If the eval step reports `about:blank`, returns `{ error: "wrong-page", ... }`,
or the batch URL/title shows `/signin`, do **not** trust a `false` result. Rerun
Step 1/2 recovery as appropriate, then retry this batched search once.

## Step 5: Respond

If the trusted Step 4 eval returned an object with tennis activity fields, say
this, using its fields. Use the `link` field for the URL. If `link` is `null`
(the lookup failed), fall back to
`https://anc.apm.activecommunities.com/portlandparks/wishlist`:

```text
Heads up! It's almost time to register for <title> on <date>:

<link>
```

Otherwise, if the trusted Step 4 eval returned `false`, say there are no open
events.

Do not say there are no open events when the eval ran on `about:blank`, returned
`{ error: "wrong-page", ... }`, or was paired with a batch URL/title on
`/signin`; recover and retry instead.

## Notes

- Always use the native `agent_browser` tool for browser steps — this is a JavaScript-rendered UI.
- The real detail link is built from the internal activity id, which is never in the page's HTML — only the public activity *number* is. Step 4 resolves number → id with a same-origin `fetch` to the `activities/list` search API (no extra auth), so the eval must stay `async` and be run as the eval step inside the wishlist batch.
- Do not use named sessions, manual browser state flags, profile flags, or direct `agent-browser` CLI commands for this skill.
- Do not manually submit the sign-in form. Use `auth login activecommunities`, then reopen the wishlist with a batched open + wait + inspection.
- If `auth login` returns `loggedIn: true` but the next batched load is still the sign-in page, suspect stale browser/session state first. Close the managed session and retry auth once before declaring the saved auth entry broken.
