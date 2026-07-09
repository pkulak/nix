---
name: alarm
description: Turn the Home Assistant Frigate person-announcement alarm on or off, or check whether it is on. Use for explicit requests like "turn on the alarm", "arm the alarm", "disable the alarm", or "is the alarm on".
---

# Alarm

This controls the Home Assistant helper `input_boolean.alarm`. When it is on, Frigate person events can trigger household broadcast announcements.

Use the `ha` helper from PATH.

## Check state

```bash
ha state input_boolean.alarm
```

Reply with a short, natural answer:

- `on` -> "The alarm is on."
- `off` -> "The alarm is off."

## Turn on / arm

Only do this when the user clearly asks to turn on, enable, or arm the alarm.

```bash
ha on input_boolean.alarm
ha state input_boolean.alarm
```

If the final state is `on`, reply: "The alarm is on."

## Turn off / disarm

Only do this when the user clearly asks to turn off, disable, or disarm the alarm.

```bash
ha off input_boolean.alarm
ha state input_boolean.alarm
```

If the final state is `off`, reply: "The alarm is off."

## Safety

This is a Home Assistant side effect. Do not change the alarm for ambiguous requests. If the user says something like "set an alarm for 7" or asks about an emergency/siren/smoke alarm, this skill does not apply.

If the `ha` command fails or the final state is not what was requested, report the useful error or final state instead of pretending it worked.
