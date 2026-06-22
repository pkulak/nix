#!/usr/bin/env python3
"""Track seen local used-item listings."""

import argparse
import datetime as dt
import json
import os
import re
import sys
from pathlib import Path
from urllib.parse import urlparse, parse_qs


def state_path() -> Path:
    override = os.environ.get("USED_LOCAL_ITEMS_STATE")
    if override:
        return Path(override).expanduser()
    cache_home = os.environ.get("XDG_CACHE_HOME")
    if cache_home:
        base = Path(cache_home).expanduser()
    else:
        base = Path.home() / ".cache"
    return base / "used-local-items" / "seen.json"


def load_state(path: Path) -> dict:
    if not path.exists():
        return {"version": 1, "seen": {}}
    with path.open() as f:
        state = json.load(f)
    state.setdefault("version", 1)
    state.setdefault("seen", {})
    return state


def save_state(path: Path, state: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    tmp = path.with_suffix(path.suffix + ".tmp")
    with tmp.open("w") as f:
        json.dump(state, f, indent=2, sort_keys=True)
        f.write("\n")
    tmp.replace(path)


def infer_source(url: str) -> str | None:
    host = urlparse(url).netloc.lower()
    if "facebook.com" in host:
        return "facebook"
    if "craigslist.org" in host:
        return "craigslist"
    if "offerup.com" in host or "offerup.co" in host:
        return "offerup"
    return None


def extract_id(url: str, source: str | None) -> str | None:
    parsed = urlparse(url)
    text = parsed.geturl()

    if source == "facebook":
        match = re.search(r"/marketplace/item/(\d+)", text)
        if match:
            return match.group(1)
        query_id = parse_qs(parsed.query).get("id", [None])[0]
        if query_id and query_id.isdigit():
            return query_id

    if source == "craigslist":
        match = re.search(r"/(\d+)\.html/?(?:[?#].*)?$", text)
        if match:
            return match.group(1)
        query_id = parse_qs(parsed.query).get("postingID", [None])[0]
        if query_id and query_id.isdigit():
            return query_id

    if source == "offerup":
        match = re.search(r"/item/detail/([^/?#]+)", text)
        if match:
            return match.group(1).rstrip("/")

    return None


def load_listings(path: Path) -> list[dict]:
    with path.open() as f:
        data = json.load(f)
    listings = data.get("listings", data) if isinstance(data, dict) else data
    if not isinstance(listings, list):
        raise SystemExit("input must be a JSON array or an object with a listings array")

    normalized = []
    for item in listings:
        if not isinstance(item, dict):
            continue
        item = dict(item)
        url = item.get("url", "")
        source = (item.get("source") or infer_source(url) or "").lower()
        item["source"] = source
        item["id"] = str(item.get("id") or extract_id(url, source) or "")
        if source and item["id"]:
            item["seenKey"] = f"{source}:{item['id']}"
        normalized.append(item)
    return normalized


def unseen(args: argparse.Namespace) -> None:
    path = state_path()
    state = load_state(path)
    seen = state.get("seen", {})
    listings = [
        item
        for item in load_listings(Path(args.listings))
        if item.get("seenKey") and item["seenKey"] not in seen
    ]
    json.dump(listings, sys.stdout, indent=2, sort_keys=True)
    sys.stdout.write("\n")


def mark(args: argparse.Namespace) -> None:
    path = state_path()
    state = load_state(path)
    now = dt.datetime.now(dt.UTC).isoformat()
    marked = 0

    for item in load_listings(Path(args.listings)):
        key = item.get("seenKey")
        if not key:
            continue
        existing = state["seen"].get(key, {})
        state["seen"][key] = {
            "firstSeen": existing.get("firstSeen", now),
            "lastSeen": now,
            "source": item.get("source"),
            "id": item.get("id"),
            "url": item.get("url"),
            "title": item.get("title"),
            "price": item.get("price"),
            "location": item.get("location"),
        }
        marked += 1

    save_state(path, state)
    json.dump({"marked": marked, "state": str(path)}, sys.stdout, indent=2, sort_keys=True)
    sys.stdout.write("\n")


def path_cmd(_: argparse.Namespace) -> None:
    print(state_path())


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest="cmd", required=True)

    unseen_parser = sub.add_parser("unseen", help="print listings not present in the seen state")
    unseen_parser.add_argument("listings")
    unseen_parser.set_defaults(func=unseen)

    mark_parser = sub.add_parser("mark", help="record listings in the seen state")
    mark_parser.add_argument("listings")
    mark_parser.set_defaults(func=mark)

    path_parser = sub.add_parser("path", help="print the state file path")
    path_parser.set_defaults(func=path_cmd)

    args = parser.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
