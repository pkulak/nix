#!/usr/bin/env python3

import argparse
import json
from datetime import datetime, time
from zoneinfo import ZoneInfo

LOCAL_TZ = ZoneInfo("America/Los_Angeles")
BLACKOUT_START = time(17, 0)
BLACKOUT_END = time(21, 0)


def parse_start(value: str) -> datetime:
    normalized = value[:-1] + "+00:00" if value.endswith("Z") else value
    try:
        start = datetime.fromisoformat(normalized)
    except ValueError as error:
        raise ValueError(f"invalid start timestamp: {value}") from error

    if start.tzinfo is None or start.utcoffset() is None:
        raise ValueError("start timestamp must include a UTC offset")

    return start.astimezone(LOCAL_TZ)


def calculate(current: int, target: int, start: datetime) -> dict[str, object]:
    if not 0 <= current <= 100:
        raise ValueError("current percentage must be between 0 and 100")
    if not 0 <= target <= 100:
        raise ValueError("target percentage must be between 0 and 100")

    start = start.astimezone(LOCAL_TZ)

    if current >= target:
        return {
            "action": "stop-now",
            "current_percent": current,
            "target_percent": target,
            "charge_minutes": 0,
            "blackout_delay_seconds": 0,
        }

    charge_minutes = (target - current) * 1.8
    charge_seconds = charge_minutes * 60
    start_epoch = start.timestamp()
    blackout_start = datetime.combine(start.date(), BLACKOUT_START, LOCAL_TZ).timestamp()
    blackout_end = datetime.combine(start.date(), BLACKOUT_END, LOCAL_TZ).timestamp()
    delay_seconds = 0.0

    if start_epoch < blackout_start:
        fire_epoch = start_epoch + charge_seconds
        if fire_epoch > blackout_start:
            delay_seconds = blackout_end - blackout_start
            fire_epoch += delay_seconds
    elif start_epoch < blackout_end:
        delay_seconds = blackout_end - start_epoch
        fire_epoch = blackout_end + charge_seconds
    else:
        fire_epoch = start_epoch + charge_seconds

    fire_at = datetime.fromtimestamp(fire_epoch, LOCAL_TZ)
    return {
        "action": "schedule",
        "current_percent": current,
        "target_percent": target,
        "charge_minutes": charge_minutes,
        "blackout_delay_seconds": round(delay_seconds),
        "fire_at": fire_at.isoformat(timespec="seconds"),
    }


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Calculate an EV charge-stop time around the 5pm–9pm charging blackout."
    )
    parser.add_argument("current", type=int, help="User-reported current charge percentage")
    parser.add_argument("target", type=int, help="Requested target charge percentage")
    parser.add_argument("start", help="RFC 3339 start timestamp with a UTC offset")
    args = parser.parse_args()

    try:
        result = calculate(args.current, args.target, parse_start(args.start))
    except ValueError as error:
        parser.error(str(error))

    print(json.dumps(result, separators=(",", ":")))


if __name__ == "__main__":
    main()
