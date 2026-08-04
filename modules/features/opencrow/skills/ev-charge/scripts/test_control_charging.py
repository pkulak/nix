#!/usr/bin/env python3

import subprocess
import unittest
from unittest.mock import patch

from control_charging import ChargerStatus, control, press_button


class FakeClock:
    def __init__(self) -> None:
        self.value = 0.0

    def now(self) -> float:
        return self.value

    def sleep(self, seconds: float) -> None:
        self.value += seconds


class StatusReader:
    def __init__(self, *statuses: ChargerStatus) -> None:
        self.statuses = list(statuses)
        self.last = statuses[-1]

    def __call__(self) -> ChargerStatus:
        if self.statuses:
            self.last = self.statuses.pop(0)
        return self.last


class ControlChargingTest(unittest.TestCase):
    def test_skips_call_when_already_started(self) -> None:
        pressed: list[str] = []
        result = control(
            "start",
            read=lambda: ChargerStatus("In Use", 6.5),
            press=lambda action: pressed.append(action),
        )
        self.assertTrue(result["ok"])
        self.assertTrue(result["already"])
        self.assertEqual(pressed, [])

    def test_confirms_start_after_home_assistant_error(self) -> None:
        clock = FakeClock()
        result = control(
            "start",
            read=StatusReader(
                ChargerStatus("Not Charging", 0),
                ChargerStatus("Not Charging", 0),
                ChargerStatus("In Use", 6.5),
            ),
            press=lambda _action: "500 Internal Server Error",
            now=clock.now,
            sleep=clock.sleep,
            verify_timeout=10,
            poll_interval=1,
        )
        self.assertTrue(result["ok"])
        self.assertEqual(result["call_error"], "500 Internal Server Error")

    def test_confirms_stop_after_home_assistant_timeout(self) -> None:
        clock = FakeClock()
        result = control(
            "stop",
            read=StatusReader(
                ChargerStatus("In Use", 6.5),
                ChargerStatus("In Use", 6.5),
                ChargerStatus("Not Charging", 0),
            ),
            press=lambda _action: "Home Assistant request timed out.",
            now=clock.now,
            sleep=clock.sleep,
            verify_timeout=10,
            poll_interval=1,
        )
        self.assertTrue(result["ok"])
        self.assertEqual(result["charger_state"], "Not Charging")

    def test_reports_unconfirmed_action(self) -> None:
        clock = FakeClock()
        result = control(
            "start",
            read=lambda: ChargerStatus("Not Charging", 0),
            press=lambda _action: "500 Internal Server Error",
            now=clock.now,
            sleep=clock.sleep,
            verify_timeout=2,
            poll_interval=1,
        )
        self.assertFalse(result["ok"])
        self.assertIn("500 Internal Server Error", result["message"])
        self.assertIn("Not Charging", result["message"])

    @patch("control_charging.run_ha")
    def test_press_button_turns_timeout_into_ambiguous_error(self, run_ha) -> None:
        run_ha.side_effect = subprocess.TimeoutExpired("ha", 75)
        self.assertIn("did not finish", press_button("stop"))


if __name__ == "__main__":
    unittest.main()
