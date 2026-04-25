---
name: download
description: Download a video from a URL using yt-dlp, rename it to a clean slug, re-upload it to the public file server, and share the link. Use when the user says "download this <url>", "get me a link for this <url>", "grab this video", "save this <url>", or any similar request to fetch and reshare a video. Also handles transforms (trim, crop, extract audio, etc.) — when a transform is requested, downloads highest quality source and transcodes to ensure frame-accurate output with proper A/V sync.
---

# Download & Re-upload

When the user provides a URL and wants a clean, shareable link to the video, follow these steps in order.

## Decide: transform or direct download?

**If the user also wants a transform** (trim, crop, scale, audio-only extract, etc.) on the downloaded video, use the **Transform flow** below. Transforms require full transcoding, so we download the highest-quality source first and transcode during the transform — this avoids the A/V desync and imprecise cuts that `-c copy` causes.

**If no transform is needed**, use the **Direct flow** — download and remux straight to MP4.

---

## Direct Flow (no transform requested)

### Step 1: Download the video

Create the temp directory and use yt-dlp with flags that ensure iOS-compatible MP4 output (h265 preferred, h264 fallback, AAC audio):

```bash
mkdir -p /tmp/ytdl
yt-dlp --merge-output-format mp4 --remux-video mp4 -S vcodec:h265,vcodec:h264,lang,quality,res,fps,acodec:aac -o "/tmp/ytdl/%(title)s.%(ext)s" "<URL>"
```

If the download fails with remux (e.g. incompatible codec like VP9/AV1 that can't remux into MP4), retry with re-encode:

```bash
yt-dlp --merge-output-format mp4 --recode-video mp4 -S vcodec:h265,vcodec:h264,lang,quality,res,fps,acodec:aac -o "/tmp/ytdl/%(title)s.%(ext)s" "<URL>"
```

### Step 2: Rename to a clean slug

The downloaded filename will be long and ugly (e.g. "Funny Cat Compilation 2024 [abc123] FULL VIDEO HD.mp4"). Rename it to a short, readable, lower-kebab-case slug based on the **content** — not the format, channel, or metadata noise.

Rules for the slug:
- 2–5 words max, lower-kebab-case
- Describe what the video **is about** or what happens in it
- Strip: channel names, year tags, resolution labels (HD/4K), emojis, brackets, "FULL VIDEO", etc.
- Keep it friendly for a non-technical audience
- Preserve the file extension

Examples:
- "Funny Cat Compilation 2024 [abc123] FULL VIDEO HD.mp4" → `funny-cats.mp4`
- "President's Speech on Economic Reform - C-SPAN.mp4" → `economic-reform-speech.mp4`
- "How to Make Sourdough Bread _ Baking Tutorial.mp4" → `sourdough-bread.mp4`

```bash
mv "/tmp/ytdl/<original-filename>" "/tmp/ytdl/<slug>.mp4"
```

### Step 3: Upload to the public server

Upload using curl:

```bash
curl -T /tmp/ytdl/<slug>.mp4 https://files.kulak.us/public/
```

### Step 4: Return the link in chat

**CRITICAL:** You must always return the download link directly in your chat response. Do not rely on the `curl` output being visible to the user. Explicitly include the URL in your reply.

```
Done! Here's your video:

https://files.kulak.us/public/<slug>.mp4
```

### Step 5: Clean up

Delete the local file:

```bash
rm /tmp/ytdl/<slug>.mp4
```

---

## Transform Flow (trim, crop, or any other transform requested)

When the user wants any transform applied to the video (e.g. "trim from 1:20 to 3:00", "crop to the left half", "extract just the audio"), do NOT use `-c copy` / stream copy — it can only cut on keyframes and causes A/V desync. Instead, download the highest-quality source and transcode during the transform.

### Step T1: Download highest-quality source

Download the best available quality **without forcing MP4 remux**. We want the purest source so the transcode has maximum fidelity to work from:

```bash
mkdir -p /tmp/ytdl
yt-dlp -S "res,fps,quality,vcodec" -o "/tmp/ytdl/%(title)s.%(ext)s" "<URL>"
```

Note the downloaded file may be `.webm`, `.mkv`, `.mp4`, etc. — that's fine, we'll transcode it next.

### Step T2: Apply the transform via transcoding

Use `ffmpeg` with **full re-encoding** (never `-c copy`) to apply transforms — stream copy can only cut on keyframes and causes A/V desync.

Combine all transforms into a single `ffmpeg` pass to avoid multi-generation quality loss.

Example trim:

```bash
ffmpeg -i "/tmp/ytdl/<source-file>" -ss <START> -to <END> -c:v libx264 -c:a aac -movflags +faststart -pix_fmt yuv420p "/tmp/ytdl/<slug>.mp4"
```

### Step T3: Rename to a clean slug

Same slug rules as the Direct flow. Append a short hint about the transform if it helps distinguish (e.g. `funny-cats-trim.mp4`).

```bash
# Only needed if the output filename doesn't already match the slug
mv "/tmp/ytdl/<current-filename>" "/tmp/ytdl/<slug>.<ext>"
```

### Step T4: Upload to the public server

```bash
curl -T /tmp/ytdl/<slug>.<ext> https://files.kulak.us/public/
```

### Step T5: Return the link in chat

**CRITICAL:** Same as Direct flow — always include the URL in your reply.

```
Done! Here's your trimmed video:

https://files.kulak.us/public/<slug>.<ext>
```

### Step T6: Clean up

Delete both the source file and the output file:

```bash
rm /tmp/ytdl/<source-file> /tmp/ytdl/<slug>.<ext>
```