#!/usr/bin/env python3

import argparse
import hashlib
import json
import os
import re
import tempfile
import unicodedata
from datetime import datetime, timezone
from io import BytesIO
from pathlib import Path
from uuid import uuid7

import requests
import yaml
from PIL import Image, ImageOps

ROOT = Path(
    os.environ.get("OPENCROW_STUFF_DIR", Path.home() / "notes" / "stuff")
).resolve()
FILES_ROOT = os.environ.get(
    "OPENCROW_STUFF_FILES_ROOT", "https://files.kulak.us/public/stuff"
)


def now():
    return datetime.now(timezone.utc).isoformat().replace("+00:00", "Z")


def slug(value):
    value = unicodedata.normalize("NFKD", value)
    value = value.encode("ascii", "ignore").decode().lower()
    return re.sub(r"[^a-z0-9]+", "-", value).strip("-") or "item"


def read_note(path):
    text = path.read_text()
    if not text.startswith("---\n"):
        raise ValueError(f"Missing front matter: {path}")
    end = text.find("\n---\n", 4)
    if end < 0:
        raise ValueError(f"Unterminated front matter: {path}")
    data = yaml.safe_load(text[4:end]) or {}
    return data, text[end + 5 :]


def write_note(path, data, body=""):
    path.parent.mkdir(parents=True, exist_ok=True)
    content = (
        "---\n"
        + yaml.safe_dump(data, allow_unicode=True, sort_keys=False)
        + "---\n"
        + body
    )
    with tempfile.NamedTemporaryFile("w", dir=path.parent, delete=False) as temporary:
        temporary.write(content)
        temporary_path = Path(temporary.name)
    os.chmod(temporary_path, 0o644)
    os.replace(temporary_path, path)


def markdown_body(value):
    return value.rstrip() + "\n" if value and value.strip() else ""


def item_paths():
    return sorted(path for path in ROOT.rglob("*.md") if path.name != "_location.md")


def relative(path):
    return str(path.relative_to(ROOT))


def location_titles(directory):
    titles = []
    current = ROOT
    for part in directory.relative_to(ROOT).parts:
        current /= part
        marker = current / "_location.md"
        if marker.is_file():
            data, _ = read_note(marker)
            titles.append(data.get("title", part))
        else:
            titles.append(part)
    return titles


def note_record(path):
    data, body = read_note(path)
    record = {
        "path": relative(path),
        "location": str(path.parent.relative_to(ROOT)),
        "location_titles": location_titles(path.parent),
        **data,
    }
    if body.strip():
        record["description"] = body.rstrip()
    return record


def resolve_note(value):
    candidate = Path(value).expanduser()
    candidates = []
    if (
        candidate.is_absolute()
        and candidate.is_file()
        and candidate.resolve().is_relative_to(ROOT)
    ):
        candidates = [candidate.resolve()]
    else:
        under_root = (ROOT / value).resolve()
        with_suffix = under_root.with_suffix(".md")
        if under_root.is_relative_to(ROOT) and under_root.is_file():
            candidates = [under_root]
        elif with_suffix.is_relative_to(ROOT) and with_suffix.is_file():
            candidates = [with_suffix]
        else:
            query = value.casefold()
            for path in item_paths():
                data, _ = read_note(path)
                if (
                    data.get("title", "").casefold() == query
                    or path.stem.casefold() == query
                ):
                    candidates.append(path)
    if len(candidates) != 1:
        raise ValueError(f"Expected one item for {value!r}, found {len(candidates)}")
    return candidates[0]


def location_paths():
    return sorted(ROOT.rglob("_location.md"))


def resolve_location(value):
    candidate = (ROOT / value).resolve()
    if candidate.is_relative_to(ROOT) and (candidate / "_location.md").is_file():
        return candidate
    query = value.casefold()
    matches = []
    for marker in location_paths():
        data, _ = read_note(marker)
        if (
            data.get("title", "").casefold() == query
            or marker.parent.name.casefold() == query
        ):
            matches.append(marker.parent)
    if len(matches) != 1:
        raise ValueError(f"Expected one location for {value!r}, found {len(matches)}")
    return matches[0]


def available_path(location, title, current=None):
    base = slug(title)
    candidate = location / f"{base}.md"
    index = 2
    while candidate.exists() and candidate != current:
        candidate = location / f"{base}-{index}.md"
        index += 1
    return candidate


def image_format(path):
    with Image.open(path) as image:
        format_name = image.format
    formats = {
        "JPEG": ("jpg", "image/jpeg"),
        "PNG": ("png", "image/png"),
        "GIF": ("gif", "image/gif"),
        "WEBP": ("webp", "image/webp"),
    }
    if format_name not in formats:
        raise ValueError(f"Unsupported image format {format_name!r}: {path}")
    return formats[format_name]


def file_sha256(path):
    digest = hashlib.sha256()
    with path.open("rb") as source:
        while chunk := source.read(1024 * 1024):
            digest.update(chunk)
    return digest.hexdigest()


def remote_matches(url, expected_sha256):
    try:
        response = requests.get(url, stream=True, timeout=(10, 300))
        if response.status_code == 404:
            return False
        response.raise_for_status()
        digest = hashlib.sha256()
        for chunk in response.iter_content(1024 * 1024):
            digest.update(chunk)
        return digest.hexdigest() == expected_sha256
    except requests.RequestException:
        return False


def upload_image(path):
    path = Path(path).expanduser().resolve()
    extension, content_type = image_format(path)
    requested_url = f"{FILES_ROOT}/{uuid7()}.{extension}"
    digest = file_sha256(path)
    try:
        with path.open("rb") as source:
            response = requests.put(
                requested_url,
                data=source,
                headers={"Content-Type": content_type},
                timeout=(10, 300),
            )
        response.raise_for_status()
    except requests.RequestException:
        if remote_matches(requested_url, digest):
            return requested_url
        raise
    location = response.headers.get("Location")
    if not location:
        location = next(
            (
                line.strip()
                for line in reversed(response.text.splitlines())
                if line.startswith("https://")
            ),
            None,
        )
    if not location:
        raise RuntimeError(f"Upload returned no Location header for {path}")
    return location


def cmd_search(args):
    terms = args.query.casefold().split()
    matches = []
    for path in item_paths():
        record = note_record(path)
        haystack = json.dumps(record, ensure_ascii=False).casefold()
        if all(term in haystack for term in terms):
            title = record.get("title", "").casefold()
            score = (
                0
                if title == args.query.casefold()
                else 1
                if args.query.casefold() in title
                else 2
            )
            matches.append((score, record))
    matches.sort(
        key=lambda value: (value[0], value[1].get("title", ""), value[1]["path"])
    )
    print(
        json.dumps(
            [record for _, record in matches[: args.limit]],
            indent=2,
            ensure_ascii=False,
        )
    )


def cmd_get(args):
    print(
        json.dumps(note_record(resolve_note(args.item)), indent=2, ensure_ascii=False)
    )


def cmd_locations(args):
    query = args.query.casefold() if args.query else ""
    records = []
    for marker in location_paths():
        data, body = read_note(marker)
        record = {"path": str(marker.parent.relative_to(ROOT)), **data}
        if body.strip():
            record["description"] = body.rstrip()
        if not query or query in json.dumps(record, ensure_ascii=False).casefold():
            records.append(record)
    print(json.dumps(records, indent=2, ensure_ascii=False))


def cmd_create(args):
    location = resolve_location(args.location)
    destination = available_path(location, args.title)
    timestamp = now()
    images = [upload_image(Path(value)) for value in args.image]
    data = {
        "title": args.title,
        "created": timestamp,
        "updated": timestamp,
    }
    if images:
        data["image"] = images[0]
    if len(images) > 1:
        data["additional_images"] = images[1:]
    if args.quantity is not None:
        data["quantity"] = args.quantity
    if args.tag:
        data["tags"] = args.tag
    write_note(destination, data, markdown_body(args.description))
    print(json.dumps(note_record(destination), indent=2, ensure_ascii=False))


def cmd_update(args):
    source = resolve_note(args.item)
    data, body = read_note(source)
    title = args.title or data.get("title")
    location = resolve_location(args.location) if args.location else source.parent
    destination = available_path(location, title, current=source)

    if args.title:
        data["title"] = args.title
    if args.description is not None:
        body = markdown_body(args.description)
    if args.clear_description:
        body = ""
    if args.quantity is not None:
        data["quantity"] = args.quantity
    if args.clear_quantity:
        data.pop("quantity", None)
    if args.tag is not None:
        data["tags"] = args.tag
    if args.clear_tags:
        data.pop("tags", None)
    if args.replace_image:
        data["image"] = upload_image(Path(args.replace_image))
    if args.add_image:
        additional = list(data.get("additional_images") or [])
        additional.extend(upload_image(Path(value)) for value in args.add_image)
        data["additional_images"] = additional
    data["updated"] = now()

    write_note(destination, data, body)
    if destination != source:
        source.unlink()
    print(json.dumps(note_record(destination), indent=2, ensure_ascii=False))


def cmd_delete(args):
    if not args.yes:
        raise ValueError("Deletion requires --yes")
    path = resolve_note(args.item)
    record = note_record(path)
    path.unlink()
    images = [record.get("image"), *record.get("additional_images", [])]
    print(
        json.dumps(
            {
                "deleted": record["path"],
                "remote_images_retained": [url for url in images if url],
            },
            indent=2,
        )
    )


def render_image(item, output, width):
    path = resolve_note(item)
    data, _ = read_note(path)
    url = data.get("image")
    if not url:
        raise ValueError(f"Item has no image: {relative(path)}")
    response = requests.get(url, timeout=(10, 300))
    response.raise_for_status()

    with Image.open(BytesIO(response.content)) as source:
        image = ImageOps.exif_transpose(source).convert("RGB")
        if image.width > width:
            height = round(image.height * width / image.width)
            image = image.resize((width, height), Image.Resampling.LANCZOS)
        suffix = hashlib.sha256(relative(path).encode()).hexdigest()[:8]
        output = (
            Path(output) if output else Path("/tmp/stuff") / f"{path.stem}-{suffix}.jpg"
        )
        output.parent.mkdir(parents=True, exist_ok=True)
        image.save(output, "JPEG", quality=85, optimize=True)
    print(output)


def quantity(value):
    number = float(value)
    return int(number) if number.is_integer() else number


def build_parser():
    parser = argparse.ArgumentParser(description="Manage the Markdown stuff inventory")
    commands = parser.add_subparsers(dest="command", required=True)

    search = commands.add_parser("search")
    search.add_argument("query")
    search.add_argument("--limit", type=int, default=20)
    search.set_defaults(func=cmd_search)

    get = commands.add_parser("get")
    get.add_argument("item")
    get.set_defaults(func=cmd_get)

    locations = commands.add_parser("locations")
    locations.add_argument("query", nargs="?")
    locations.set_defaults(func=cmd_locations)

    create = commands.add_parser("create")
    create.add_argument("--title", required=True)
    create.add_argument("--location", required=True)
    create.add_argument("--image", action="append", default=[])
    create.add_argument("--description")
    create.add_argument("--quantity", type=quantity)
    create.add_argument("--tag", action="append", default=[])
    create.set_defaults(func=cmd_create)

    update = commands.add_parser("update")
    update.add_argument("item")
    update.add_argument("--title")
    update.add_argument("--location")
    update.add_argument("--description")
    update.add_argument("--clear-description", action="store_true")
    update.add_argument("--quantity", type=quantity)
    update.add_argument("--clear-quantity", action="store_true")
    update.add_argument("--tag", action="append")
    update.add_argument("--clear-tags", action="store_true")
    update.add_argument("--replace-image")
    update.add_argument("--add-image", action="append", default=[])
    update.set_defaults(func=cmd_update)

    delete = commands.add_parser("delete")
    delete.add_argument("item")
    delete.add_argument("--yes", action="store_true")
    delete.set_defaults(func=cmd_delete)

    image = commands.add_parser("image")
    image.add_argument("item")
    image.add_argument("--output")
    image.add_argument("--width", type=int, default=800)
    image.set_defaults(
        func=lambda args: render_image(args.item, args.output, args.width)
    )

    return parser


def main():
    args = build_parser().parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
