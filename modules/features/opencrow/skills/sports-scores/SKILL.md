---
name: sports-scores
description: Look up sports scores, upcoming games, and schedules using the ESPN API. Use when anyone asks about a team's next game, current score, game time, or recent results — or asks about all games in a league today. Handles NBA, NFL, MLB, NHL, MLS, EPL, WNBA, and college sports. Triggers on phrases like "when is the next game", "what's the score", "did the Blazers win", "when do the Timbers play", "any NBA games on today", "did they win their last game", etc.
---

# Sports Scores

Look up game schedules and live scores via the ESPN public API.

## Step 1: Resolve the sport/league

The ESPN API uses sport/league paths. If the user mentions a specific league by name or abbreviation, map it:

| User says | sport | league |
|---|---|---|
| NBA | basketball | nba |
| WNBA | basketball | wnba |
| NFL | football | nfl |
| College Football / CFB / NCAAF | football | college-football |
| MLB | baseball | mlb |
| NHL / hockey | hockey | nhl |
| MLS / soccer (US) | soccer | usa.1 |
| EPL / Premier League / English soccer | soccer | eng.1 |
| Men's College Basketball / March Madness | basketball | mens-college-basketball |

If the user doesn't specify a sport but mentions a team name, the team lookup in Step 2 will determine the league.

If the user asks about a league generically (e.g. "what NBA games are on today?"), note the sport/league and go directly to **Step 4** — skip Step 2 and Step 3, and omit the `--arg tid` / `select()` filter to get all games for that league.

## Step 2: Identify the team

Read the sidecar file at the path relative to this skill directory: `teams.json`

It is a JSON array of `[id, abbreviation, displayName, shortDisplayName, sport, league]`.

Search for the team by matching the user's query against:
- `displayName` (e.g. "Portland Trail Blazers")
- `shortDisplayName` (e.g. "Trail Blazers")
- `abbreviation` (e.g. "POR")

Use a case-insensitive substring match. The user may say "blazer" or "blazers" when the team is "Portland Trail Blazers" — match flexibly.

Also apply these unofficial nickname aliases before matching:

| User says | Match as |
|---|---|
| Habs | Montreal Canadiens |

If multiple teams match (e.g. "Portland" could be Trail Blazers or Timbers), prefer the one in the sport the user seems to be asking about (basketball keywords → NBA, soccer keywords → MLS, etc). If still ambiguous, ask the user to clarify.

From the match, extract: `id`, `sport`, and `league`.

## Step 3: Determine what to look up

- **"When is the next game?" / "next game" / schedule questions** → go to Step 4
- **"What's the score?" / "how are they doing?"** → go to Step 5
- **"Did they win?" / "did they win their last game?" / "last result"** → go to Step 6
- **Both or unclear** → do the relevant steps

## Step 4: Get next game

Run:

```bash
curl -s "http://site.api.espn.com/apis/site/v2/sports/{sport}/{league}/teams/{id}" | jq '.team.nextEvent'
```

If the array is empty, say "No upcoming games scheduled."

Otherwise, take the first event and extract:

```bash
curl -s "http://site.api.espn.com/apis/site/v2/sports/{sport}/{league}/teams/{id}" | jq '.team.nextEvent[0] | {name, date, status: .status.type.detail, competitions: [.competitions[] | {status: .status.type.detail, broadcasts: [.broadcasts[]?.media.shortName], venue: .venue?.fullName, competitors: [.competitors[] | {team: .team.shortDisplayName, score: .score, homeAway: .homeAway, record: (.records // [] | map(.summary) | join(" "))}]}]}'
```

Present the information naturally:

- **Scheduled game:** "The **Trail Blazers** play the **Spurs** on Tuesday, April 21 at 5:00 PM PDT in San Antonio (Frost Bank Center). TV: NBC, streaming: Peacock."
- **In-progress game:** "The **Trail Blazers** are currently playing the **Spurs** — POR 98, SA 87 (4th quarter)."
- **Completed game:** "The **Trail Blazers** beat the **Spurs** 112-105."

Use the `date` field (ISO 8601 UTC) and convert to Pacific time for the user. Round to the nearest sensible time.

## Step 5: Get today's scores

**For a specific team**, run:

```bash
curl -s "http://site.api.espn.com/apis/site/v2/sports/{sport}/{league}/scoreboard" | jq --arg tid "{id}" '[.events[] | select(.competitions[].competitors[].team.id == $tid) | {name, date, status: .status.type.detail, statusState: .status.type.state, competitions: [.competitions[] | {status: .status.type.detail, competitors: [.competitors[] | {team: .team.shortDisplayName, score: .score, winner: .winner, homeAway: .homeAway, record: (.records // [] | map(.summary) | join(" "))}]}]}]'
```

**For all games in a league**, omit the team filter:

```bash
curl -s "http://site.api.espn.com/apis/site/v2/sports/{sport}/{league}/scoreboard" | jq '[.events[] | {name, date, status: .status.type.detail, statusState: .status.type.state, competitions: [.competitions[] | {status: .status.type.detail, competitors: [.competitors[] | {team: .team.shortDisplayName, score: .score, winner: .winner, homeAway: .homeAway, record: (.records // [] | map(.summary) | join(" "))}]}]}]'
```

If no results, there are no games today. Say so.

Otherwise, format the results — show opponent, score, game status, and game time. For league-wide queries, list all games for the day.

For completed games, note the winner with the final score.
For in-progress games, show the current score and period/quarter/inning.
For scheduled games today, show the game time.

## Step 6: Find a past result ("did they win?")

When the user asks about a completed game ("did the Blazers win?", "last result", etc.), the scoreboard API supports a `dates` parameter in `YYYYMMDD` format.

First check today. If the team didn't play today, check yesterday, and keep going back up to 7 days.

Use `date +%Y%m%d` for today's date and `date -d "N days ago" +%Y%m%d` for past dates.

For each date, run:

```bash
curl -s "http://site.api.espn.com/apis/site/v2/sports/{sport}/{league}/scoreboard?dates={YYYYMMDD}" | jq --arg tid "{id}" '[.events[] | select(.competitions[].competitors[].team.id == $tid) | {name, date, status: .status.type.detail, statusState: .status.type.state, competitions: [.competitions[] | {status: .status.type.detail, competitors: [.competitors[] | {team: .team.shortDisplayName, score: .score, winner: .winner, homeAway: .homeAway}]}]}]'
```

As soon as you get a non-empty result with `statusState` of `post` (completed), report it:
- **Win:** "The **Trail Blazers** beat the **Spurs** 112-105 on Saturday."
- **Loss:** "The **Trail Blazers** lost to the **Spurs** 98-111 on Saturday."
- **Tie** (soccer): "The **Timbers** drew with **LAFC** 2-2 on Saturday."

If you reach 7 days back with no completed game found, say so: "The **Trail Blazers** haven't played in the last 7 days."

If you find a game that is currently in progress on today's date, report it as a live score instead of continuing to search.

## Tips

- Always convert UTC times to Pacific (PDT is UTC-7, PST is UTC-8)
- team records (like "52-30") come from the `records` field in competitor objects
- The `teams.json` sidecar covers: NBA, NFL, MLB, NHL, MLS, EPL, WNBA, Men's College Basketball, College Football
- If a team isn't found in `teams.json`, try the ESPN teams API directly: `curl -s "http://site.api.espn.com/apis/site/v2/sports/{sport}/{league}/teams"` and search there
- Do not comment on individual steps — respond once with the answer