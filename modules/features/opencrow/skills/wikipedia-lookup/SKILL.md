---
name: wikipedia-lookup
description: Look up facts, names, dates, and other information using the Wikipedia API. Use whenever you need to answer a factual question about people, places, organizations, history, or any topic Wikipedia would cover.
---

# Wikipedia Lookup

Look up factual information via the Wikipedia API using `curl` and `jq`.

## Search for articles

When you need to find information but aren't sure of the exact article title:

```bash
curl -s "https://en.wikipedia.org/w/api.php?action=query&list=search&srsearch=YOUR+SEARCH+TERMS&format=json" | jq '.query.search[0:3] | .[].title'
```

This returns the top 3 matching article titles. Pick the best match, then fetch its content.

## Fetch article content

Once you have an article title (replace spaces with underscores):

```bash
curl -s "https://en.wikipedia.org/w/api.php?action=query&titles=ARTICLE_TITLE&prop=revisions&rvprop=content&format=json&redirects=1" | jq -r '.query.pages | to_entries[0].value.revisions[0]["*"]' | head -80
```

- `redirects=1` follows redirects (e.g., common aliases → main article)
- `head -80` gets the first 80 lines (usually covers the infobox and intro)
- Adjust `head` as needed for longer articles

## Tips

- Wikipedia wikitext uses `'''bold'''` for the article subject and `[[links]]` for related articles
- The infobox near the top has key facts: founded dates, locations, population, etc.
- For short facts (e.g., a founding year), search results snippets may already contain the answer — no need to fetch the full article
- If the first search result isn't right, try different search terms or fetch multiple results
- Always URL-encode special characters in search terms (spaces become `+` or `%20`)
