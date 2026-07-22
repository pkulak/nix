---
name: air-quality
description: Check the current outdoor air quality, AQI, or PM2.5 near the house. Use when asked whether the air is clean, smoky, healthy, or safe for outdoor activity.
---

# Air Quality

Run the helper script:

```bash
bash "$OPENCROW_PI_SKILLS_DIR/air-quality/scripts/air_quality.sh"
```

Report the returned AQI, category, and PM2.5 reading concisely. Do not expose the raw JSON unless asked.
