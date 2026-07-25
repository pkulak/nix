---
name: ev-charge
description: Schedule or execute an EV charging stop from a user-provided current charge percentage, defaulting to an 80% target and accounting for the daily 5pm–9pm charging blackout. Use when someone says they just plugged in, asks to charge the car to a percentage, requests a charging timer, or when an [EV_CHARGE_STOP] reminder fires.
---

# EV Charge

Schedule a one-shot reminder that will stop EV charging at the estimated target. Charging gains 1 percentage point every 2 minutes, but never runs from 5pm through 9pm in the `America/Los_Angeles` timezone.

The Home Assistant stop button is `button.cph50_stop_charging`.

## Required input and message context

The current charge percentage must come explicitly from the user's message. There is no entity from which to read it. Never query Home Assistant for the current charge, infer it from earlier charging sessions, or guess it. If the user did not provide an unambiguous whole-number percentage, ask for it and take no action.

Use these context tags from the current user message:

- `<time>`: charging start time for a phrase such as "just plugged in"
- `<room-id>`: Matrix room to notify when charging is stopped
- `<message-id>`: message to react to after successful setup

Copy tag values exactly. The target defaults to 80% when the user does not give one. Current and target percentages must each be whole numbers from 0 through 100.

## Calculate the stop time

Do not calculate the deadline mentally. Resolve `scripts/calculate_charge_stop.py` relative to this `SKILL.md`, then run:

```bash
python3 scripts/calculate_charge_stop.py CURRENT TARGET START_TIMESTAMP
```

Pass the RFC 3339 value from `<time>` as `START_TIMESTAMP`, preserving its UTC offset. The helper returns JSON.

It applies these rules:

- Required active charging time is `(target - current) * 2` minutes.
- Charging is paused during the half-open interval `[5:00pm, 9:00pm)` local time.
- A charge finishing exactly at 5pm needs no pause.
- A charge extending beyond 5pm resumes at 9pm.
- A charge started during the pause waits until 9pm before gaining charge.
- If current charge is already at or above the target, the action is `stop-now`.

If the helper rejects the input, explain the problem and take no action.

## Replace an old EV timer

After calculation succeeds, call `remind_list`. Cancel every pending reminder whose prompt contains the exact marker `[EV_CHARGE_STOP]` by calling `remind_cancel` with its ID. This prevents a timer from an earlier charging session from stopping the current one.

## Stop immediately

When the helper returns `"action":"stop-now"`, run:

```bash
ha call button press '{"entity_id":"button.cph50_stop_charging"}'
```

Inspect the exit status and output for a Home Assistant error. On success, respond only with the check-mark reaction described below. On failure, report the useful error in text; do not claim charging stopped.

## Schedule the stop

When the helper returns `"action":"schedule"`, call `remind_at` with its `fire_at` value and a self-contained prompt in this form, replacing every placeholder with the actual value:

```text
[EV_CHARGE_STOP]
The scheduled EV charging stop is due. It was set from CURRENT% for an estimated TARGET% target.

Immediately run this exact command:
ha call button press '{"entity_id":"button.cph50_stop_charging"}'

Do not merely remind the user and do not schedule another reminder. Inspect the command's exit status and output. Your final response must begin with this exact routing line:
<send-to>ROOM_ID</send-to>

On success, put exactly this on the next line:
The Leaf is done charging.

On failure, put a short, natural explanation of the useful Home Assistant error on the next line and do not claim charging stopped.
```

The reminder prompt must contain the exact `<room-id>` value from the original user message even if the current OpenCrow instance normally has a default room.

Only treat setup as successful after `remind_at` returns a reminder ID. If scheduling fails, report the useful error in text.

## Successful setup response

After either a reminder was successfully scheduled or an immediate stop succeeded, respond with no prose. Output only this Matrix reaction control tag, using the exact current `<message-id>` value:

```text
<react id="MESSAGE_ID">✅</react>
```

Do not combine the reaction with a textual confirmation. Reminder triggers do not have a user message to react to, so when the timer fires, send the concise completion or failure message to the room recorded in the reminder instead.
