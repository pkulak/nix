#!/usr/bin/env python3

import unittest
from datetime import datetime

from calculate_charge_stop import LOCAL_TZ, calculate, parse_start


class CalculateChargeStopTest(unittest.TestCase):
    def calculate_at(self, current: int, target: int, start: str) -> dict[str, object]:
        return calculate(current, target, parse_start(start))

    def test_finishes_before_blackout(self) -> None:
        result = self.calculate_at(50, 64, "2026-07-25T16:30:00-07:00")
        self.assertEqual(result["fire_at"], "2026-07-25T16:58:00-07:00")
        self.assertEqual(result["blackout_delay_seconds"], 0)

    def test_finishes_exactly_at_blackout(self) -> None:
        result = self.calculate_at(50, 65, "2026-07-25T16:30:00-07:00")
        self.assertEqual(result["fire_at"], "2026-07-25T17:00:00-07:00")
        self.assertEqual(result["blackout_delay_seconds"], 0)

    def test_crossing_blackout_adds_four_hours(self) -> None:
        result = self.calculate_at(50, 66, "2026-07-25T16:30:00-07:00")
        self.assertEqual(result["fire_at"], "2026-07-25T21:02:00-07:00")
        self.assertEqual(result["blackout_delay_seconds"], 4 * 60 * 60)

    def test_requested_afternoon_example(self) -> None:
        result = self.calculate_at(23, 60, "2026-07-25T16:30:00-07:00")
        self.assertEqual(result["charge_minutes"], 74)
        self.assertEqual(result["fire_at"], "2026-07-25T21:44:00-07:00")

    def test_starting_during_blackout_waits_until_nine(self) -> None:
        result = self.calculate_at(23, 80, "2026-07-25T20:00:00-07:00")
        self.assertEqual(result["charge_minutes"], 114)
        self.assertEqual(result["blackout_delay_seconds"], 60 * 60)
        self.assertEqual(result["fire_at"], "2026-07-25T22:54:00-07:00")

    def test_exactly_five_waits_until_nine(self) -> None:
        result = self.calculate_at(50, 60, "2026-07-25T17:00:00-07:00")
        self.assertEqual(result["fire_at"], "2026-07-25T21:20:00-07:00")

    def test_exactly_nine_charges_immediately(self) -> None:
        result = self.calculate_at(50, 60, "2026-07-25T21:00:00-07:00")
        self.assertEqual(result["fire_at"], "2026-07-25T21:20:00-07:00")
        self.assertEqual(result["blackout_delay_seconds"], 0)

    def test_at_or_above_target_stops_now(self) -> None:
        at_target = self.calculate_at(80, 80, "2026-07-25T12:00:00-07:00")
        above_target = self.calculate_at(90, 80, "2026-07-25T12:00:00-07:00")
        self.assertEqual(at_target["action"], "stop-now")
        self.assertEqual(above_target["action"], "stop-now")

    def test_rejects_invalid_percentages(self) -> None:
        start = datetime(2026, 7, 25, 12, tzinfo=LOCAL_TZ)
        with self.assertRaisesRegex(ValueError, "current percentage"):
            calculate(-1, 80, start)
        with self.assertRaisesRegex(ValueError, "target percentage"):
            calculate(20, 101, start)

    def test_requires_timestamp_offset(self) -> None:
        with self.assertRaisesRegex(ValueError, "UTC offset"):
            parse_start("2026-07-25T12:00:00")


if __name__ == "__main__":
    unittest.main()
