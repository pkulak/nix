---
name: ev-charge
description: Reliably start or stop the Leaf's ChargePoint charging now or at a requested time, and schedule a percentage-based charging stop after someone plugs in. Use for requests such as "start charging", "stop charging", "start charging at 11am", "I plugged in at 30%", or when an [EV_CHARGE_START] or [EV_CHARGE_STOP] reminder fires.
---

# EV Charge

Control the Leaf's ChargePoint charger through Home Assistant. Keep immediate controls, scheduled controls, and plug-in percentage timers in this one skill because they share the same entities, reminders, and reliability handling.

## Reliable charging control

Never press the ChargePoint Home Assistant buttons directly. ChargePoint commands can return HTTP 500 or outlive a short client timeout even when they succeed. Resolve `scripts/control_charging.py` relative to this `SKILL.md` and use it for every start or stop:

```bash
python3 scripts/control_charging.py start
python3 scripts/control_charging.py stop
```

Always give the Bash tool a timeout of **300 seconds**. The helper waits through ChargePoint's acknowledgement delay and verifies the resulting charger state and power. It prints JSON and exits zero only after the requested state is confirmed. On a nonzero exit, report its `message` value naturally and do not claim the action succeeded.

## Immediate start or stop

For an explicit request such as "start charging" or "stop charging", run the matching helper action immediately. A current charge percentage is not required.

After confirmed success, respond with no prose. Output only this reaction using the exact current `<message-id>`:

```text
<react id="MESSAGE_ID">✅</react>
```

This also applies when the helper says the charger was already in the requested state.

## Start or stop at a requested time

For a future request such as "start charging at 11am" or "stop charging tonight at midnight":

1. Copy the current message's `<room-id>` exactly.
2. Call `remind_list` and cancel every pending reminder containing the same action marker: `[EV_CHARGE_START]` for a start or `[EV_CHARGE_STOP]` for a stop. Do not cancel the opposite action's reminder unless the user asks.
3. Call `remind_at` for the requested time with a self-contained prompt following this template. Replace every placeholder.

```text
[EV_CHARGE_ACTION_MARKER]
The scheduled EV charging ACTION is due.

Immediately run this exact command with a Bash tool timeout of 300 seconds:
cd "$OPENCROW_PI_SKILLS_DIR/ev-charge" && python3 scripts/control_charging.py ACTION

Inspect the helper's JSON and exit status. Your final response must begin with this exact routing line:
<send-to>ROOM_ID</send-to>

On confirmed success, put exactly this on the next line:
SUCCESS_TEXT

On failure, put the helper's short, natural `message` value on the next line and do not claim the action succeeded.
```

Use these replacements:

- Start: marker `[EV_CHARGE_START]`, action `start`, success text `The Leaf has started charging.`
- Stop: marker `[EV_CHARGE_STOP]`, action `stop`, success text `The Leaf is done charging.`

Only treat scheduling as successful after `remind_at` returns a reminder ID. Then respond with only the check-mark reaction above. Reminder triggers have no user message to react to, so they send the result to the recorded room instead.

## Plug-in percentage timer

When someone says they plugged in and gives the current percentage, schedule a stop at the estimated target. The target defaults to 80%. Charging gains one percentage point every **1.8 minutes** and pauses daily from 5pm through 9pm in `America/Los_Angeles`.

The current percentage must come explicitly from the user's message. Never query Home Assistant for it, infer it from an earlier session, or guess. Current and target percentages must be whole numbers from 0 through 100. If the current percentage is missing or ambiguous, ask for it and take no action.

Use the exact user-provided charging start time when present. For a phrase such as "just plugged in", use the RFC 3339 value from `<time>`, preserving its UTC offset.

Run the calculator rather than calculating mentally:

```bash
python3 scripts/calculate_charge_stop.py CURRENT TARGET START_TIMESTAMP
```

The helper accounts for the 5pm–9pm blackout and returns JSON:

- `"action":"stop-now"`: run `control_charging.py stop` immediately with a 300-second Bash timeout.
- `"action":"schedule"`: cancel every pending `[EV_CHARGE_STOP]` reminder, then schedule the returned `fire_at` time using the stop reminder template above. Add this context sentence after the marker: `The stop was set from CURRENT% for an estimated TARGET% target.`

If calculation, control, or scheduling fails, report the useful error and do not react as though it succeeded. After a confirmed immediate stop or a successfully created reminder, respond with only the check-mark reaction.
