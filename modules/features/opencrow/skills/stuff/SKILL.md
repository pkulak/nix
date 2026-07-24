---
name: stuff
description: Find, show, add, update, move, or delete household belongings in the Markdown stuff inventory, often called "the bins." Use when asked to search or check the bins, where something is, what is stored in a location, to remember a new item, or to change an item's title, location, image, quantity, tags, or description.
---

# Stuff Inventory

The inventory is stored as Markdown under `~/notes/stuff/`. Location comes from the note's directory. Titles, image URLs, dates, quantities, and tags are stored in front matter; the item or location description is the Markdown body. Full-resolution images live on the local file server.

Use the helper from this skill directory rather than maintaining a separate index or image manifest:

```bash
cd "$OPENCROW_PI_SKILLS_DIR/stuff"
python3 scripts/stuff.py --help
```

The Markdown files are the source of truth. Remote image names are UUIDv7 values and do not change when notes move.

## Find and read items

Search titles, paths, tags, and descriptions:

```bash
python3 scripts/stuff.py search "cordless drill"
python3 scripts/stuff.py search "camping" --limit 20
```

Read one known item:

```bash
python3 scripts/stuff.py get "house/garage/cordless-drill.md"
```

List or search locations before creating or moving an item:

```bash
python3 scripts/stuff.py locations
python3 scripts/stuff.py locations garage
```

Report the item's human-readable location from `location_titles`, not just the slugged path.

### Send an image when available

When answering a find/read request, an image is useful whenever the matching item has one. Download and resize the primary image to at most 800 pixels wide:

```bash
out="$(python3 scripts/stuff.py image 'house/garage/cordless-drill.md')"
```

Then attach the exact path printed by the helper with OpenCrow's sendfile tag:

```text
The cordless drill is in the House / Garage.
<sendfile>/tmp/stuff/cordless-drill-a1b2c3d4.jpg</sendfile>
```

For one to four clear matches, send a resized image for each item that has one. For broad result sets, summarize first and send images only for the most relevant few rather than flooding the chat. Never send the full-resolution remote image unless the user explicitly asks for it.

## Create an item

Use an existing location path or an unambiguous location title. OpenCrow chat attachments are available as local files and can be passed with `--image`:

```bash
python3 scripts/stuff.py create \
  --title "Cordless Drill" \
  --location "house/garage" \
  --image "/path/to/chat-attachment.jpg" \
  --tag tools \
  --description "18V drill and charger"
```

Use repeated `--image` and `--tag` options for multiple values. The first image becomes `image`; later images become `additional_images`. Images are uploaded byte-for-byte to `https://files.kulak.us/public/stuff/<uuidv7>.<extension>`, and the server's returned `Location` is stored in the note. `--description` writes Markdown body content, not a front-matter field.

If the requested location is ambiguous or does not exist, ask where to put the item rather than inventing a location.

## Update or move an item

Search first when the item is not uniquely identified. The update helper can rename or move the Markdown file while leaving image URLs unchanged:

```bash
python3 scripts/stuff.py update "house/garage/cordless-drill.md" \
  --location "house/workshop"

python3 scripts/stuff.py update "house/workshop/cordless-drill.md" \
  --title "18V Cordless Drill" \
  --quantity 2 \
  --tag tools \
  --tag power-tools
```

Other updates:

```bash
python3 scripts/stuff.py update ITEM --description "New description"
python3 scripts/stuff.py update ITEM --clear-description
python3 scripts/stuff.py update ITEM --clear-quantity
python3 scripts/stuff.py update ITEM --clear-tags
python3 scripts/stuff.py update ITEM --replace-image /path/to/new-primary.jpg
python3 scripts/stuff.py update ITEM --add-image /path/to/another-photo.jpg
```

Replacing an image changes the note to a newly uploaded URL. The old remote image is retained.

## Delete an item

Deletion is destructive. Confirm with the user before running it:

```bash
python3 scripts/stuff.py delete "house/garage/cordless-drill.md" --yes
```

This deletes only the Markdown record. It reports the remote image URLs but does not delete them from the file server.

## Response style

Keep responses concise. For finds, give the item title and human-readable location, plus a resized image when available. For writes, say what was created, changed, moved, or deleted and where the note now lives. Do not expose raw JSON unless asked.
