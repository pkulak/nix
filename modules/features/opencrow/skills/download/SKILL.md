---
name: download
description: Download a video from a URL using yt-dlp, rename it to a clean slug, re-upload it to the public file server, and share the link. Use when the user says "download this <url>", "get me a link for this <url>", "grab this video", "save this <url>", or any similar request to fetch and reshare a video.
---

# Download & Re-upload

When the user provides a URL and wants a clean, shareable link to the video, follow these steps in order.

## Step 1: Download the video

Create the temp directory and use yt-dlp with flags that ensure iOS-compatible MP4 output (h265 preferred, h264 fallback, AAC audio):

```bash
mkdir -p /tmp/ytdl
yt-dlp --merge-output-format mp4 --remux-video mp4 -S vcodec:h265,vcodec:h264,lang,quality,res,fps,acodec:aac -o "/tmp/ytdl/%(title)s.%(ext)s" "<URL>"
```

If the download fails with remux (e.g. incompatible codec like VP9/AV1 that can't remux into MP4), retry with re-encode:

```bash
yt-dlp --merge-output-format mp4 --recode-video mp4 -S vcodec:h265,vcodec:h264,lang,quality,res,fps,acodec:aac -o "/tmp/ytdl/%(title)s.%(ext)s" "<URL>"
```

## Step 2: Rename to a clean slug

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

## Step 3: Upload to the public server

Upload using curl:

```bash
curl -T /tmp/ytdl/<slug>.mp4 https://files.kulak.us/public/
```

## Step 4: Return the link in chat

**CRITICAL:** You must always return the download link directly in your chat response. Do not rely on the `curl` output being visible to the user. Explicitly include the URL in your reply.

```
Done! Here's your video:

https://files.kulak.us/public/<slug>.mp4
```

## Step 5: Clean up

Delete the local file:

```bash
rm /tmp/ytdl/<slug>.mp4
```
