---
name: frigate
description: Answer questions about Phil's Frigate home cameras, recent alerts, people/packages/animals outside, the front door/front yard/backyard, or "what's going on" after a camera alert. Use for requests to check, show, describe, or send recent Frigate camera activity.
---

# Frigate Home Cameras

Use Phil's local Frigate API. It is available on the local network with no auth:

```text
http://debian.home:5000/api
```

Cameras:

- `doorbell` — front door / porch
- `front` — front of the house / front yard / street side
- `back` — backyard

## Response style: media first

For camera questions, the best answer is usually a short sentence plus an inline visual. Prefer attaching a GIF or image with OpenCrow's sendfile tag:

```text
Looks like a delivery at the front door.
<sendfile>/tmp/frigate/review-1782584120.259385-cmn0sa.gif</sendfile>
```

OpenCrow strips the tag and sends the file as a Matrix attachment. Do not make users click links for normal snapshots or preview GIFs.

Use this media priority:

1. Review preview GIF for "what happened?" / alert follow-up / recent motion.
2. Event preview GIF if you have an event ID but no review ID.
3. Event snapshot if the GIF is not ready yet.
4. Latest camera snapshot for "is anyone there now?" / current-state questions.
5. Contact sheet of latest snapshots when the user asks broadly about all outside cameras and there is no obvious recent event.

Preview GIFs are normally small; attach them inline. If a requested clip/export is over 10 MiB, upload it to the private local file server instead and return the link:

```bash
curl -T /tmp/file-name.ext https://files.kulak.us/public/
```

Then reply with `https://files.kulak.us/public/file-name.ext`.

## Safety and privacy

- Use read-only `GET` endpoints unless the user explicitly asks for a mutating action.
- Do not delete events, mark reviews viewed/unviewed, retain/unretain events, submit to Frigate+, or change labels/descriptions.
- Be careful with identity. If Frigate's `sub_label` says a person is Phil/Charlie/etc, you can say "Frigate labeled this as Phil." Otherwise say "looks like" rather than claiming certainty.
- Keep text concise. The visual is usually the useful part.

## Camera mapping

Map natural language to cameras:

- front door, porch, doorstep, doorbell -> `doorbell`
- front, front yard, street, driveway, sidewalk -> `front,doorbell`
- back, backyard, back yard -> `back`
- outside, cameras, around the house, what is going on -> `doorbell,front,back`

If the user asks a follow-up immediately after a camera alert, prefer the camera(s) implied by the alert text and search the last 30 minutes.

## Basic setup

Use a temp directory for media:

```bash
mkdir -p /tmp/frigate
```

Use local time in user-facing responses. Frigate timestamps are Unix seconds; convert with:

```bash
date -d @1782584120 '+%-I:%M %p'
```

## Workflow A: "what's going on?" / alert follow-up

1. Decide cameras from the user's wording.
2. Look for active in-progress events first:

```bash
curl -fsS "http://debian.home:5000/api/events?limit=10&in_progress=1&include_thumbnails=0&cameras=doorbell,front" | jq
```

3. Look for recent alert review items. Use about 30 minutes unless the user gives a different time window:

```bash
after="$(python3 - <<'PY'
import time
print(time.time() - 1800)
PY
)"

curl -fsS "http://debian.home:5000/api/review?limit=10&severity=alert&after=$after&cameras=doorbell,front" | jq
```

4. Pick the most relevant review. Review items contain grouped detections in `.data.detections`.
5. Download a review preview GIF:

```bash
review_id="1782584120.259385-cmn0sa"
out="/tmp/frigate/review-$review_id.gif"
curl -fsS "http://debian.home:5000/api/review/$review_id/preview?format=gif" -o "$out"
file "$out"
```

6. If the GIF request fails or the file is not a GIF, wait briefly and retry once:

```bash
sleep 3
curl -fsS "http://debian.home:5000/api/review/$review_id/preview?format=gif" -o "$out"
file "$out"
```

7. If the GIF is still unavailable, attach an event snapshot from the first detection:

```bash
event_id="1782584119.66894-u73jix"
out="/tmp/frigate/event-$event_id.jpg"
curl -fsS "http://debian.home:5000/api/events/$event_id/snapshot.jpg?bbox=1&timestamp=1&quality=85" -o "$out"
file "$out"
```

8. Read the downloaded image/GIF if needed for visual understanding, then respond with concise text and the attachment:

```text
Looks like a person came up to the porch and then left.
<sendfile>/tmp/frigate/review-1782584120.259385-cmn0sa.gif</sendfile>
```

## Workflow B: current state / "is anyone still there?"

Use latest snapshots, especially for active/current questions:

```bash
camera="doorbell"
out="/tmp/frigate/$camera-latest.jpg"
curl -fsS "http://debian.home:5000/api/$camera/latest.jpg?height=720&bbox=1&timestamp=1" -o "$out"
file "$out"
```

Read the image, then answer with the snapshot attached:

```text
I don't see anyone at the front door now.
<sendfile>/tmp/frigate/doorbell-latest.jpg</sendfile>
```

For a broad outside check, download all three latest frames and make a contact sheet:

```bash
mkdir -p /tmp/frigate
for camera in doorbell front back; do
  curl -fsS "http://debian.home:5000/api/$camera/latest.jpg?height=480&timestamp=1" \
    -o "/tmp/frigate/$camera-latest.jpg"
done

magick montage \
  -label doorbell /tmp/frigate/doorbell-latest.jpg \
  -label front /tmp/frigate/front-latest.jpg \
  -label back /tmp/frigate/back-latest.jpg \
  -geometry 640x480+8+8 -tile 3x1 \
  -background '#222' -fill white -pointsize 24 \
  /tmp/frigate/outside-now.jpg
```

If `magick montage` is not available, try the `montage` command from ImageMagick.

## Workflow C: event or object search

For questions like "was that a delivery?", "did a cat go by?", or "show me the last dog/person/car", use Frigate event search:

```bash
curl -fsS "http://debian.home:5000/api/events/search?query=delivery&limit=5&include_thumbnails=0&cameras=doorbell,front" | jq
```

Then fetch a preview GIF or snapshot for the best event:

```bash
event_id="1782584119.66894-u73jix"
out="/tmp/frigate/event-$event_id.gif"
curl -fsS "http://debian.home:5000/api/events/$event_id/preview.gif" -o "$out"
file "$out"
```

If unavailable, use the event snapshot:

```bash
out="/tmp/frigate/event-$event_id.jpg"
curl -fsS "http://debian.home:5000/api/events/$event_id/snapshot.jpg?bbox=1&timestamp=1&quality=85" -o "$out"
```

## Useful endpoints

```text
GET /api/version
GET /api/config
GET /api/stats
GET /api/review?limit=10&severity=alert&after=<unix>&cameras=<csv>
GET /api/review/{review_id}
GET /api/review/event/{event_id}
GET /api/review/{review_id}/preview?format=gif
GET /api/events?limit=10&include_thumbnails=0&cameras=<csv>
GET /api/events?limit=10&in_progress=1&include_thumbnails=0
GET /api/events/search?query=<text>&limit=5&include_thumbnails=0&cameras=<csv>
GET /api/events/{event_id}
GET /api/events/{event_id}/preview.gif
GET /api/events/{event_id}/snapshot.jpg?bbox=1&timestamp=1&quality=85
GET /api/events/{event_id}/clip.mp4
GET /api/{camera}/latest.jpg?height=720&bbox=1&timestamp=1
```

The OpenAPI spec is available locally if endpoint details are needed:

```text
http://debian.home:5000/api/openapi.json
```
