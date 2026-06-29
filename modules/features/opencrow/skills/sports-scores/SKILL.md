---
name: sports-scores
description: Look up sports scores, upcoming games, and schedules using the ESPN API helper script. Use when anyone asks about a team's next game, current score, game time, recent result, or asks about all games in a league today. Handles NBA, NFL, MLB, NHL, MLS, EPL, WNBA, men's college basketball, and college football.
---

# Sports Scores

Use the deterministic helper script in this skill directory. Do not read `teams.json` into context; the script owns team data, ESPN API calls, Pacific time conversion, and schema normalization.

You interpret the user's request. The script does not understand English questions. Decide whether the user wants:

- a team's next game: `team next`
- today's/live score for a team: `scoreboard --team-id ...`
- all games in a league today: `scoreboard`
- a recent completed result / "did they win?": `team last-result`
- team lookup/disambiguation: `teams search`

Run commands from this skill directory:

```bash
cd "$OPENCROW_PI_SKILLS_DIR/sports-scores"
```

## Favorite team IDs

Use these directly when the user clearly means one of them; this avoids a team-search round trip.

| User says | sport | league | team-id |
|---|---|---|---|
| Blazers, Trail Blazers, Rip City | basketball | nba | 22 |
| Timbers, PTFC | soccer | usa.1 | 9723 |
| Portland Fire | basketball | wnba | 132052 |
| Chargers, LA Chargers, Bolts | football | nfl | 24 |
| Canucks | hockey | nhl | 22 |
| Habs, Canadiens | hockey | nhl | 10 |
| Oregon Ducks football, Duck football, Ducks, Oregon football | football | college-football | 2483 |

## League IDs

Common ESPN league paths:

| User says | sport | league |
|---|---|---|
| NBA | basketball | nba |
| WNBA | basketball | wnba |
| NFL | football | nfl |
| College Football, CFB, NCAAF | football | college-football |
| MLB | baseball | mlb |
| NHL, hockey | hockey | nhl |
| MLS, US soccer | soccer | usa.1 |
| EPL, Premier League, English soccer | soccer | eng.1 |
| Men's college basketball, March Madness | basketball | mens-college-basketball |

You can inspect supported leagues with:

```bash
python3 scripts/sports_scores.py leagues
```

## Team lookup

When the team is not in the favorites table, search by team name, short name, abbreviation, or alias:

```bash
python3 scripts/sports_scores.py teams search --query "canadiens"
python3 scripts/sports_scores.py teams search --query "portland"
python3 scripts/sports_scores.py teams search --query "portland" --league nba
python3 scripts/sports_scores.py teams search --query "ducks" --sport football --league college-football
```

If multiple teams match, use the user's sport/league context to choose. If still ambiguous, ask a short clarification question.

## Next game

```bash
python3 scripts/sports_scores.py team next \
  --sport basketball \
  --league nba \
  --team-id 22
```

If `.event` is `null`, say there is no upcoming game scheduled. Otherwise format naturally. Use the returned `datePacific`, `relativeDatePacific`, status, venue, broadcasts, and competitors.

Emphasize **today** or **tomorrow** in the final response when applicable.

## Today's/live scoreboard

For one team:

```bash
python3 scripts/sports_scores.py scoreboard \
  --sport basketball \
  --league nba \
  --team-id 22
```

For all games in a league today:

```bash
python3 scripts/sports_scores.py scoreboard \
  --sport basketball \
  --league nba
```

For a specific date:

```bash
python3 scripts/sports_scores.py scoreboard \
  --sport basketball \
  --league nba \
  --date 20260627
```

If there are no events, say there are no games for that team/league today. For league-wide queries, list all games concisely.

## Last result / did they win?

```bash
python3 scripts/sports_scores.py team last-result \
  --sport basketball \
  --league nba \
  --team-id 22 \
  --days 7
```

If `result.outcome` is:

- `win`: say the team beat the opponent with the score and day.
- `loss`: say the team lost to the opponent with the score and day.
- `tie`: for soccer, say they drew; otherwise say tied.
- `in_progress`: report the current live score instead of looking further back.
- `null`: say they have not completed a game in the searched window.

## Response style

Respond once with the answer, not the raw JSON. Be concise.

Examples:

```text
The **Trail Blazers** play the **Spurs** **today** at 5:00 PM PDT in San Antonio.
```

```text
The **Timbers** beat **LAFC** 2–1 on Saturday.
```

```text
There are no NBA games today.
```
