---
name: used-local-items
description: Search Craigslist, Facebook Marketplace, and OfferUp for local used items, remembering listing IDs so repeated checks only report new listings. Use when asked to find, check, watch, or search local used/secondhand items or marketplace deals.
---

# Used Local Items

Use this for local secondhand item searches. Only search these sources:

- Craigslist
- Facebook Marketplace
- OfferUp

Do not substitute eBay, Google/Kagi results, retailer pages, or other classifieds unless the user explicitly asks to expand the scope.

Use the native `agent_browser` tool for all site interaction and extraction in this skill. Do not use raw `curl`, `wget`, scraping libraries, or direct `agent-browser` shell commands unless the user explicitly asks for a non-browser workflow.

## Defaults

Unless the user says otherwise:

- Location: Portland/Vancouver metro.
- Radius: about 40 miles.
- Sort newest/recent first when the site supports it.
- Prefer local pickup used listings; skip shipped-only listings, promoted ads, retailers, and obvious spam.
- Ask a follow-up only if the item/query itself is missing. Otherwise use reasonable price/location/category judgment and proceed.

## Seen state

Keep seen listing state outside the skill directory:

```text
${XDG_CACHE_HOME:-$HOME/.cache}/used-local-items/seen.json
```

Use the helper in this skill directory to filter and mark seen listings:

```bash
python3 scripts/seen.py path
python3 scripts/seen.py unseen /tmp/used-local-items-candidates.json > /tmp/used-local-items-unseen.json
python3 scripts/seen.py mark /tmp/used-local-items-reported.json
```

The helper accepts a JSON array, or an object with a `listings` array. Each listing should look like:

```json
{
  "source": "facebook",
  "id": "2130173024227474",
  "url": "https://www.facebook.com/marketplace/item/2130173024227474/",
  "title": "1980 Vintage Travertine Coffee Table",
  "price": "$699",
  "location": "Portland, OR"
}
```

Always use stable listing IDs from the listing URL; listings without a source and ID are ignored by the helper:

- Facebook Marketplace: `/marketplace/item/<id>`
- Craigslist: final numeric `<id>.html`
- OfferUp: `/item/detail/<id>`

Workflow:

1. Collect candidate listings from all three sources.
2. Write candidates to `/tmp/used-local-items-candidates.json`.
3. Run `python3 scripts/seen.py unseen ...` from this skill directory.
4. Evaluate only unseen listings against the user's criteria.
5. Write the listings you actually report to `/tmp/used-local-items-reported.json`.
6. Run `python3 scripts/seen.py mark ...` so they do not show up next time.

If the user asks to start tracking or set a baseline, mark all current matching listings and say the baseline is saved instead of reporting every current listing.

## Craigslist

Use the Portland Craigslist all-for-sale search by default:

```text
https://portland.craigslist.org/search/sss?query=<url-encoded-query>&sort=date&postal=97214&search_distance=40&hasPic=1
```

Add `min_price` and/or `max_price` query parameters when the user gives a price range.

After loading the page, run this JavaScript with `agent_browser eval --stdin`:

```javascript
[...document.querySelectorAll('.gallery-card')]
  .map(card => {
    const a = card.querySelector('a.posting-title[href]') || card.querySelector('a[href*=".html"]');
    if (!a) return null;
    const url = a.href.replace(/\.html\/$/, '.html');
    const id = url.match(/\/(\d+)\.html/)?.[1];
    const meta = card.querySelector('.meta')?.innerText?.trim() || '';
    const lines = card.innerText.split('\n').map(s => s.trim()).filter(Boolean);
    return {
      source: 'craigslist',
      id,
      url,
      title: a.textContent.trim(),
      price: card.querySelector('.priceinfo')?.textContent?.trim() || card.querySelector('.price')?.textContent?.trim() || '',
      location: lines.length >= 2 ? lines[lines.length - 2] : meta,
      age: lines.find(s => /ago$/.test(s)) || ''
    };
  })
  .filter(item => item && item.id);
```

## Facebook Marketplace

For the first Facebook command in a run, open with the real browser profile:

```json
{ "args": ["--profile", "Default", "open", "https://www.facebook.com/marketplace/portland/search/?query=<url-encoded-query>&sortBy=creation_time_descend"], "sessionMode": "fresh" }
```

Follow-up browser calls should reuse that same implicit session.

Important automation notes:

- Facebook often shows a login/QR modal even when public Marketplace results are loaded behind it.
- If the snapshot only shows `Log in with QR code`, `Email or phone number`, or a generic login dialog, click the `Close` button, then wait and snapshot again.
- Do not log in or message sellers. Public search results and listing pages are usually readable after closing the modal.
- The result links' accessible names include title, price, location, and `listing <id>`; this is more reliable than trying to read image cards.

Extract results with:

```javascript
[...document.querySelectorAll('a[href*="/marketplace/item/"]')]
  .map(a => {
    const url = a.href;
    const id = url.match(/\/marketplace\/item\/(\d+)/)?.[1];
    const label = a.getAttribute('aria-label') || a.innerText.replace(/\n/g, ', ');
    const noListing = label.replace(/,?\s*listing\s+\d+.*$/i, '').trim();
    const priceMatch = noListing.match(/(?:^|,\s*)(FREE|\$[\d,]+(?:\.\d{2})?)/i);
    const price = priceMatch ? priceMatch[1] : '';
    const before = priceMatch ? noListing.slice(0, priceMatch.index).replace(/,\s*$/, '').trim() : noListing;
    const after = priceMatch ? noListing.slice(priceMatch.index + priceMatch[0].length).replace(/^,\s*/, '').trim() : '';
    return {
      source: 'facebook',
      id,
      url: `https://www.facebook.com/marketplace/item/${id}/`,
      title: before,
      price,
      location: after
    };
  })
  .filter(item => item.id && item.title);
```

For a direct Facebook share/listing URL, open it, close the login modal if needed, and use `get text body` or the page metadata to extract details. Normalize the URL to `https://www.facebook.com/marketplace/item/<id>/` before saving state.

## OfferUp

Use OfferUp search with recent-first sorting:

```text
https://offerup.com/search?q=<url-encoded-query>&sort=-posted
```

OfferUp usually uses the browser's saved/default location. If results are not local, use the site location control to set Portland, OR, then search again.

Extract results with:

```javascript
[...document.querySelectorAll('a[href*="/item/detail/"]')]
  .map(a => {
    const url = a.href;
    const id = url.match(/\/item\/detail\/([^/?#]+)/)?.[1];
    const label = a.getAttribute('aria-label') || a.innerText.replace(/\n/g, ' ');
    if (/\bPromoted\b/i.test(label)) return null;
    const priceMatch = label.match(/(?:^|\s)(FREE|\$\d[\d,]*(?:\.\d{2})?)/i);
    const price = priceMatch ? priceMatch[1] : '';
    const title = priceMatch ? label.slice(0, priceMatch.index).trim() : label.trim();
    const afterPrice = priceMatch ? label.slice(priceMatch.index + priceMatch[0].length).trim() : '';
    const location = afterPrice.replace(/^in\s+/i, '').replace(/\s+Promoted$/i, '').trim();
    return {
      source: 'offerup',
      id,
      url: `https://offerup.com/item/detail/${id}`,
      title,
      price,
      location
    };
  })
  .filter(item => item && item.id && item.title);
```

## Reporting

Report only unseen relevant listings. Keep it concise and include:

- Title
- Price
- Location
- Source
- URL
- One short note if there is an obvious reason it matches or does not match the request well

If there are no unseen relevant listings and no source had a notable failure, respond exactly:

```text
NO_REPLY
```

If one source failed or blocked automation, mention that source explicitly and still report results from the others. If every source failed, briefly say what failed instead of `NO_REPLY`.
