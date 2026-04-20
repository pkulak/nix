---
name: Transcribe
description: Transcribe audio and video file attachments (voice messages, audio files, video files) to text. Use this skill automatically whenever a user sends a voice message or media file.
---

# Transcribe

When a user sends an audio or video file, transcribe it and treat the result as their message.

## How to transcribe

```bash
curl -s https://api.openai.com/v1/audio/transcriptions \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -F "file=@<FILE_PATH>" \
  -F "model=gpt-4o-transcribe" \
  -F "response_format=text"
```
