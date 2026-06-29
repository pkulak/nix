#!/usr/bin/env python3
"""Deterministic ESPN sports data helper for the sports-scores skill."""

from __future__ import annotations

import argparse
import datetime as dt
import json
import re
import sys
import unicodedata
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path
from zoneinfo import ZoneInfo

BASE_URL = "http://site.api.espn.com/apis/site/v2/sports"
PACIFIC = ZoneInfo("America/Los_Angeles")
SKILL_DIR = Path(__file__).resolve().parents[1]
TEAMS_PATH = SKILL_DIR / "teams.json"

DEFAULT_LEAGUES = [
    {
        "sport": "basketball",
        "league": "nba",
        "name": "NBA",
        "aliases": ["nba", "pro basketball"],
    },
    {
        "sport": "basketball",
        "league": "wnba",
        "name": "WNBA",
        "aliases": ["wnba", "women's basketball"],
    },
    {
        "sport": "football",
        "league": "nfl",
        "name": "NFL",
        "aliases": ["nfl", "pro football"],
    },
    {
        "sport": "football",
        "league": "college-football",
        "name": "College Football",
        "aliases": ["college football", "cfb", "ncaaf"],
    },
    {
        "sport": "baseball",
        "league": "mlb",
        "name": "MLB",
        "aliases": ["mlb", "baseball"],
    },
    {
        "sport": "hockey",
        "league": "nhl",
        "name": "NHL",
        "aliases": ["nhl", "hockey"],
    },
    {
        "sport": "soccer",
        "league": "usa.1",
        "name": "MLS",
        "aliases": ["mls", "major league soccer"],
    },
    {
        "sport": "soccer",
        "league": "eng.1",
        "name": "English Premier League",
        "aliases": ["epl", "premier league", "english soccer"],
    },
    {
        "sport": "basketball",
        "league": "mens-college-basketball",
        "name": "Men's College Basketball",
        "aliases": ["men's college basketball", "college basketball", "march madness", "ncaam"],
    },
]

FAVORITE_ALIASES = {
    ("basketball", "nba", "22"): ["blazers", "blazer", "rip city"],
    ("soccer", "usa.1", "9723"): ["timbers", "ptfc"],
    ("basketball", "wnba", "132052"): ["portland fire"],
    ("football", "nfl", "24"): ["chargers", "bolts", "la chargers"],
    ("hockey", "nhl", "22"): ["canucks"],
    ("hockey", "nhl", "10"): ["habs", "canadiens"],
    ("football", "college-football", "2483"): ["ducks", "oregon ducks", "oregon football"],
}

FAVORITE_TEAMS = [
    {
        "id": "2483",
        "abbreviation": "ORE",
        "displayName": "Oregon Ducks",
        "shortDisplayName": "Ducks",
        "sport": "football",
        "league": "college-football",
        "aliases": FAVORITE_ALIASES[("football", "college-football", "2483")],
    }
]


def fail(message: str, code: int = 1) -> None:
    print(message, file=sys.stderr)
    raise SystemExit(code)


def emit(data: object) -> None:
    json.dump(data, sys.stdout, indent=2, sort_keys=True)
    sys.stdout.write("\n")


def normalize_text(value: str) -> str:
    value = unicodedata.normalize("NFKD", value).encode("ascii", "ignore").decode("ascii")
    value = value.lower().replace("&", " and ")
    value = re.sub(r"[^a-z0-9]+", " ", value)
    return re.sub(r"\s+", " ", value).strip()


def singularish(value: str) -> str:
    value = normalize_text(value)
    if len(value) > 3 and value.endswith("s"):
        return value[:-1]
    return value


def load_database() -> dict:
    with TEAMS_PATH.open() as f:
        raw = json.load(f)

    if isinstance(raw, list):
        teams = [
            {
                "id": str(row[0]),
                "abbreviation": row[1],
                "displayName": row[2],
                "shortDisplayName": row[3],
                "sport": row[4],
                "league": row[5],
                "aliases": [],
            }
            for row in raw
        ]
        leagues = DEFAULT_LEAGUES
    else:
        teams = raw.get("teams", [])
        leagues = raw.get("leagues", DEFAULT_LEAGUES)

    by_key = {(t["sport"], t["league"], str(t["id"])): t for t in teams}
    for key, aliases in FAVORITE_ALIASES.items():
        if key in by_key:
            existing = by_key[key].setdefault("aliases", [])
            for alias in aliases:
                if alias not in existing:
                    existing.append(alias)
    for team in FAVORITE_TEAMS:
        key = (team["sport"], team["league"], team["id"])
        if key not in by_key:
            teams.append(team)

    for team in teams:
        team["id"] = str(team["id"])
        team.setdefault("aliases", [])

    return {"version": 2, "leagues": leagues, "teams": teams}


def league_name(db: dict, sport: str, league: str) -> str:
    for item in db["leagues"]:
        if item["sport"] == sport and item["league"] == league:
            return item.get("name", league.upper())
    return league.upper()


def team_identity(team: dict, db: dict | None = None) -> dict:
    sport = team.get("sport", "")
    league = team.get("league", "")
    out = {
        "id": str(team.get("id", "")),
        "abbreviation": team.get("abbreviation", ""),
        "displayName": team.get("displayName", team.get("name", "")),
        "shortDisplayName": team.get("shortDisplayName", team.get("displayName", team.get("name", ""))),
        "sport": sport,
        "league": league,
    }
    if db:
        out["leagueName"] = league_name(db, sport, league)
    return out


def find_team(db: dict, sport: str, league: str, team_id: str) -> dict | None:
    team_id = str(team_id)
    for team in db["teams"]:
        if team["sport"] == sport and team["league"] == league and str(team["id"]) == team_id:
            return team
    return None


def match_team(query: str, team: dict) -> tuple[int, list[str]]:
    q = normalize_text(query)
    q_singular = singularish(q)
    if not q:
        return 0, []

    candidates = [
        ("displayName", team.get("displayName", "")),
        ("shortDisplayName", team.get("shortDisplayName", "")),
        ("abbreviation", team.get("abbreviation", "")),
    ] + [(f"alias:{alias}", alias) for alias in team.get("aliases", [])]

    best = 0
    matched: list[str] = []
    q_tokens = set(q.split())

    for label, value in candidates:
        n = normalize_text(str(value))
        if not n:
            continue
        n_singular = singularish(n)
        n_tokens = set(n.split())
        score = 0
        reason = ""

        if q == n or q_singular == n_singular:
            score = 100
            reason = f"{label}:exact"
        elif label == "abbreviation" and q == n:
            score = 95
            reason = "abbreviation:exact"
        elif label != "abbreviation" and q_tokens and q_tokens <= n_tokens:
            score = 80
            reason = f"{label}:tokens"
        elif label != "abbreviation" and len(q) >= 4 and (q in n or q_singular in n_singular):
            score = 75
            reason = f"{label}:contains"
        elif label != "abbreviation" and len(n) >= 4 and n in q:
            score = 70
            reason = f"query-contains:{label}"

        if score > best:
            best = score
            matched = [reason]
        elif score and score == best:
            matched.append(reason)

    return best, matched


def search_teams(args: argparse.Namespace) -> None:
    db = load_database()
    results = []
    for team in db["teams"]:
        if args.sport and team["sport"] != args.sport:
            continue
        if args.league and team["league"] != args.league:
            continue
        score, matched = match_team(args.query, team)
        if score:
            item = team_identity(team, db)
            item["aliases"] = team.get("aliases", [])
            item["matchScore"] = score
            item["matched"] = matched
            results.append(item)

    results.sort(
        key=lambda item: (
            -item["matchScore"],
            item["leagueName"],
            item["displayName"],
        )
    )
    emit(results[: args.limit])


def fetch_json(url: str) -> dict:
    request = urllib.request.Request(url, headers={"User-Agent": "opencrow-sports-scores/1"})
    try:
        with urllib.request.urlopen(request, timeout=15) as response:
            return json.load(response)
    except urllib.error.HTTPError as exc:
        fail(f"ESPN API returned HTTP {exc.code}: {url}")
    except urllib.error.URLError as exc:
        fail(f"Could not reach ESPN API: {exc.reason}")
    except TimeoutError:
        fail("Timed out contacting ESPN API")


def parse_espn_datetime(value: str | None) -> dt.datetime | None:
    if not value:
        return None
    if value.endswith("Z"):
        value = value[:-1] + "+00:00"
    try:
        parsed = dt.datetime.fromisoformat(value)
    except ValueError:
        return None
    if parsed.tzinfo is None:
        parsed = parsed.replace(tzinfo=dt.timezone.utc)
    return parsed.astimezone(PACIFIC)


def relative_date(local: dt.datetime | None) -> str | None:
    if local is None:
        return None
    today = dt.datetime.now(PACIFIC).date()
    delta = (local.date() - today).days
    if delta == 0:
        return "today"
    if delta == 1:
        return "tomorrow"
    if delta == -1:
        return "yesterday"
    if -6 <= delta <= 6:
        return local.strftime("%A")
    return local.strftime("%b %-d, %Y")


def normalize_score(value: object) -> str | None:
    if value in (None, ""):
        return None
    if isinstance(value, dict):
        value = value.get("displayValue", value.get("value"))
    if value in (None, ""):
        return None
    return str(value)


def normalize_competitor(item: dict) -> dict:
    team = item.get("team", {})
    records = item.get("records") or []
    return {
        "id": str(team.get("id", "")),
        "abbreviation": team.get("abbreviation", ""),
        "displayName": team.get("displayName", ""),
        "shortDisplayName": team.get("shortDisplayName", team.get("displayName", "")),
        "homeAway": item.get("homeAway"),
        "score": normalize_score(item.get("score")),
        "winner": item.get("winner") if "winner" in item else None,
        "records": [record.get("summary", "") for record in records if record.get("summary")],
    }


def normalize_event(event: dict) -> dict:
    local = parse_espn_datetime(event.get("date"))
    competitions = event.get("competitions") or []
    competition = competitions[0] if competitions else {}
    status_type = (event.get("status") or {}).get("type") or competition.get("status", {}).get("type", {})

    broadcasts = []
    for broadcast in competition.get("broadcasts") or []:
        media = broadcast.get("media") or {}
        name = media.get("shortName") or media.get("name") or broadcast.get("names")
        if isinstance(name, list):
            broadcasts.extend(str(x) for x in name if x)
        elif name:
            broadcasts.append(str(name))

    competitors = [normalize_competitor(item) for item in competition.get("competitors") or []]

    return {
        "id": str(event.get("id", "")),
        "name": event.get("name") or event.get("shortName") or "",
        "shortName": event.get("shortName") or "",
        "date": event.get("date"),
        "datePacific": local.isoformat() if local else None,
        "relativeDatePacific": relative_date(local),
        "status": {
            "state": status_type.get("state"),
            "detail": status_type.get("detail"),
            "shortDetail": status_type.get("shortDetail"),
            "completed": status_type.get("completed"),
        },
        "venue": (competition.get("venue") or {}).get("fullName"),
        "broadcasts": sorted(set(broadcasts)),
        "competitors": competitors,
    }


def team_next(args: argparse.Namespace) -> None:
    db = load_database()
    url = f"{BASE_URL}/{args.sport}/{args.league}/teams/{urllib.parse.quote(str(args.team_id))}"
    data = fetch_json(url)
    team_data = data.get("team") or {}
    db_team = find_team(db, args.sport, args.league, args.team_id)
    team = db_team or {
        "id": str(team_data.get("id", args.team_id)),
        "abbreviation": team_data.get("abbreviation", ""),
        "displayName": team_data.get("displayName", team_data.get("name", "")),
        "shortDisplayName": team_data.get("shortDisplayName", team_data.get("displayName", "")),
        "sport": args.sport,
        "league": args.league,
    }
    events = team_data.get("nextEvent") or []
    emit({"team": team_identity(team, db), "event": normalize_event(events[0]) if events else None})


def scoreboard(args: argparse.Namespace) -> None:
    db = load_database()
    date_arg = args.date or dt.datetime.now(PACIFIC).strftime("%Y%m%d")
    query = f"?{urllib.parse.urlencode({'dates': date_arg})}"
    url = f"{BASE_URL}/{args.sport}/{args.league}/scoreboard{query}"
    data = fetch_json(url)
    events = [normalize_event(event) for event in data.get("events") or []]
    if args.team_id:
        team_id = str(args.team_id)
        events = [
            event
            for event in events
            if any(competitor.get("id") == team_id for competitor in event.get("competitors", []))
        ]

    emit(
        {
            "sport": args.sport,
            "league": args.league,
            "leagueName": league_name(db, args.sport, args.league),
            "date": date_arg,
            "events": events,
        }
    )


def score_value(value: object) -> int | None:
    if value in (None, ""):
        return None
    try:
        return int(value)
    except (TypeError, ValueError):
        try:
            return int(float(str(value)))
        except ValueError:
            return None


def result_for_event(event: dict, team_id: str) -> dict | None:
    competitors = event.get("competitors", [])
    team = next((item for item in competitors if item.get("id") == team_id), None)
    opponent = next((item for item in competitors if item.get("id") != team_id), None)
    if not team:
        return None

    state = event.get("status", {}).get("state")
    if state != "post":
        return {"outcome": "in_progress" if state == "in" else "scheduled"}

    team_score = score_value(team.get("score"))
    opponent_score = score_value(opponent.get("score") if opponent else None)
    winner = team.get("winner")
    if winner is True:
        outcome = "win"
    elif winner is False and opponent and opponent.get("winner") is True:
        outcome = "loss"
    elif team_score is not None and opponent_score is not None:
        if team_score > opponent_score:
            outcome = "win"
        elif team_score < opponent_score:
            outcome = "loss"
        else:
            outcome = "tie"
    else:
        outcome = "completed"

    return {
        "outcome": outcome,
        "team": team.get("shortDisplayName") or team.get("displayName"),
        "teamScore": team_score,
        "opponent": (opponent or {}).get("shortDisplayName") or (opponent or {}).get("displayName"),
        "opponentScore": opponent_score,
    }


def last_result(args: argparse.Namespace) -> None:
    today = dt.datetime.now(PACIFIC).date()
    team_id = str(args.team_id)
    searched = []

    for offset in range(args.days + 1):
        day = today - dt.timedelta(days=offset)
        date_arg = day.strftime("%Y%m%d")
        params = urllib.parse.urlencode({"dates": date_arg})
        url = f"{BASE_URL}/{args.sport}/{args.league}/scoreboard?{params}"
        data = fetch_json(url)
        events = [normalize_event(event) for event in data.get("events") or []]
        matches = [event for event in events if any(c.get("id") == team_id for c in event.get("competitors", []))]
        searched.append(date_arg)

        in_progress = next((event for event in matches if event.get("status", {}).get("state") == "in"), None)
        if in_progress:
            emit(
                {
                    "teamId": team_id,
                    "searchedDates": searched,
                    "event": in_progress,
                    "result": result_for_event(in_progress, team_id),
                }
            )
            return

        completed = next((event for event in matches if event.get("status", {}).get("state") == "post"), None)
        if completed:
            emit(
                {
                    "teamId": team_id,
                    "searchedDates": searched,
                    "event": completed,
                    "result": result_for_event(completed, team_id),
                }
            )
            return

    emit({"teamId": team_id, "searchedDates": searched, "event": None, "result": None})


def leagues(_: argparse.Namespace) -> None:
    emit(load_database()["leagues"])


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    subparsers = parser.add_subparsers(dest="command", required=True)

    leagues_parser = subparsers.add_parser("leagues", help="List supported leagues")
    leagues_parser.set_defaults(func=leagues)

    teams_parser = subparsers.add_parser("teams", help="Team lookup commands")
    teams_subparsers = teams_parser.add_subparsers(dest="teams_command", required=True)
    search_parser = teams_subparsers.add_parser("search", help="Search teams by name, abbreviation, or alias")
    search_parser.add_argument("--query", required=True)
    search_parser.add_argument("--sport")
    search_parser.add_argument("--league")
    search_parser.add_argument("--limit", type=int, default=20)
    search_parser.set_defaults(func=search_teams)

    team_parser = subparsers.add_parser("team", help="Team-specific ESPN commands")
    team_subparsers = team_parser.add_subparsers(dest="team_command", required=True)
    next_parser = team_subparsers.add_parser("next", help="Get a team's next event")
    next_parser.add_argument("--sport", required=True)
    next_parser.add_argument("--league", required=True)
    next_parser.add_argument("--team-id", required=True)
    next_parser.set_defaults(func=team_next)

    last_parser = team_subparsers.add_parser("last-result", help="Find a team's most recent completed result")
    last_parser.add_argument("--sport", required=True)
    last_parser.add_argument("--league", required=True)
    last_parser.add_argument("--team-id", required=True)
    last_parser.add_argument("--days", type=int, default=7)
    last_parser.set_defaults(func=last_result)

    scoreboard_parser = subparsers.add_parser("scoreboard", help="Get normalized ESPN scoreboard data")
    scoreboard_parser.add_argument("--sport", required=True)
    scoreboard_parser.add_argument("--league", required=True)
    scoreboard_parser.add_argument("--date", help="YYYYMMDD; defaults to today in Pacific time")
    scoreboard_parser.add_argument("--team-id")
    scoreboard_parser.set_defaults(func=scoreboard)

    args = parser.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
