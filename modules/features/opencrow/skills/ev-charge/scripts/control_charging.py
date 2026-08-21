#!/usr/bin/env python3

import argparse
import json
import subprocess
import time
from dataclasses import dataclass
from typing import Callable

BUTTONS = {
    "start": "button.cph50_start_charging",
    "stop": "button.cph50_stop_charging",
}
CHARGER_STATE_ENTITY = "sensor.cph50_charger_state"
POWER_ENTITY = "sensor.cph50_power_output"
CALL_TIMEOUT_SECONDS = 75
VERIFY_TIMEOUT_SECONDS = 210
POLL_INTERVAL_SECONDS = 5
STOP_RETRY_DELAY_SECONDS = 30
PAST_TENSE = {"start": "started", "stop": "stopped"}


@dataclass(frozen=True)
class ChargerStatus:
    state: str
    power_kw: float | None
    error: str | None = None


def run_ha(args: list[str], timeout: int) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        ["ha", *args],
        capture_output=True,
        text=True,
        timeout=timeout,
        check=False,
    )


def command_error(result: subprocess.CompletedProcess[str]) -> str:
    return " ".join(f"{result.stderr}\n{result.stdout}".split()) or (
        f"Home Assistant command exited with status {result.returncode}."
    )


def read_status() -> ChargerStatus:
    errors: list[str] = []
    state_result = run_ha(["state", CHARGER_STATE_ENTITY], 10)
    if state_result.returncode == 0:
        state = state_result.stdout.strip()
    else:
        state = "unknown"
        errors.append(command_error(state_result))

    power_result = run_ha(["state", POWER_ENTITY], 10)
    try:
        power_kw = (
            float(power_result.stdout.strip()) if power_result.returncode == 0 else None
        )
    except ValueError:
        power_kw = None
    if power_result.returncode != 0:
        errors.append(command_error(power_result))

    return ChargerStatus(state, power_kw, "; ".join(errors) or None)


def press_button(action: str) -> str | None:
    data = json.dumps({"entity_id": BUTTONS[action]}, separators=(",", ":"))
    try:
        result = run_ha(["call", "button", "press", data], CALL_TIMEOUT_SECONDS)
    except subprocess.TimeoutExpired:
        return (
            f"Home Assistant did not finish the {action} request within "
            f"{CALL_TIMEOUT_SECONDS} seconds."
        )

    return None if result.returncode == 0 else command_error(result)


def desired_state(action: str, status: ChargerStatus) -> bool:
    state = status.state.casefold()
    if action == "start":
        return state == "in use" or (
            status.power_kw is not None and status.power_kw > 0.1
        )
    return state in {"not charging", "fully charged"} and (
        status.power_kw is None or status.power_kw <= 0.1
    )


def control(
    action: str,
    *,
    read: Callable[[], ChargerStatus] = read_status,
    press: Callable[[str], str | None] = press_button,
    now: Callable[[], float] = time.monotonic,
    sleep: Callable[[float], None] = time.sleep,
    verify_timeout: int = VERIFY_TIMEOUT_SECONDS,
    poll_interval: int = POLL_INTERVAL_SECONDS,
    stop_retry_delay: int = STOP_RETRY_DELAY_SECONDS,
) -> dict[str, object]:
    status = read()
    past_tense = PAST_TENSE[action]
    if desired_state(action, status):
        return {
            "ok": True,
            "action": action,
            "already": True,
            "charger_state": status.state,
            "power_kw": status.power_kw,
            "message": f"Charging was already {past_tense}.",
        }

    call_error = press(action)
    verify_started = now()
    deadline = verify_started + verify_timeout
    stop_retry_at = verify_started + stop_retry_delay
    stop_retried = False

    while True:
        status = read()
        if desired_state(action, status):
            return {
                "ok": True,
                "action": action,
                "already": False,
                "charger_state": status.state,
                "power_kw": status.power_kw,
                "call_error": call_error,
                "message": f"Charging {past_tense} successfully.",
            }

        current_time = now()
        if (
            action == "stop"
            and not stop_retried
            and stop_retry_at <= current_time < deadline
        ):
            # The ChargePoint integration can swallow a failed API command and
            # still return success from Home Assistant.
            retry_error = press(action)
            stop_retried = True
            if retry_error:
                call_error = (
                    retry_error
                    if call_error is None
                    else f"{call_error}; retry: {retry_error}"
                )
            continue

        remaining = deadline - current_time
        if remaining <= 0:
            break
        sleep(min(poll_interval, remaining))

    details = f'Last charger state was "{status.state}"'
    if status.power_kw is not None:
        details += f" at {status.power_kw:g} kW"
    details += "."
    message = (
        f"Could not confirm that charging {past_tense} within {verify_timeout} seconds."
    )
    if call_error:
        message += f" {call_error}"
    if status.error:
        message += f" Status check error: {status.error}"
    message += f" {details}"

    return {
        "ok": False,
        "action": action,
        "already": False,
        "charger_state": status.state,
        "power_kw": status.power_kw,
        "call_error": call_error,
        "status_error": status.error,
        "message": message,
    }


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Reliably start or stop ChargePoint charging through Home Assistant."
    )
    parser.add_argument("action", choices=BUTTONS)
    args = parser.parse_args()

    try:
        result = control(args.action)
    except (OSError, subprocess.SubprocessError) as error:
        result = {
            "ok": False,
            "action": args.action,
            "message": f"Could not run the Home Assistant charging command: {error}",
        }

    print(json.dumps(result, separators=(",", ":")))
    raise SystemExit(0 if result["ok"] else 1)


if __name__ == "__main__":
    main()
