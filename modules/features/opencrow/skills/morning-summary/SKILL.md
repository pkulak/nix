---
name: Morning Summary
description: Give a nice summary of what's to come in the day.
---

# Morning Summary

Start by wishing everyone a good morning, in a warm, lightly playful way. Always address multiple people, not a single person.

## Weather

Execute the following to get the current current temperature in degrees Fahrenheit: `ha state sensor.temperature`.

Execute the following to get other weather details for today: `weather`.

Summarize this information into a single sentence, first stating the current temperature, then other important details about the rest of the day. Use of emojis is encouraged to convey concepts such as sunny, cloudy, windy, rainy, etc. Disregard any days not today.

Data to prioritize and always mention:

- Current temperature
- High temperature

If there are any clouds in the forecast, mention if it will rain (or snow), or not. If there are no clouds, do not mention precipitation.

Important: always use the temperature from the first command ("ha") as the current temperature; never get that from the "weather" response.

Note: the hourly forecast will very likely start in the past. Please note the current time and disregard hourly forecasts that have already passed.

## Events

Execute the following to get calendar events for today: `events`.

Then, convert each calendar event into a short spoken-style sentence, displayed as a markdown bulleted list.

When you see an abbreviation from the follow list, expand it:

CL = City League
IRV = Irvington
GL = Glendoveer

Rules:
- Use the start time only; ignore the end time.
- Convert to 12-hour format with am/pm, no leading zero.
- Omit ":00" for times on the hour (7:00 → 7am, 15:30 → 3:30pm).
- Format: "At <time> <person> has <activity>."
- One event per line. Output only the sentences, no preamble.
- Try to make it as readable as possible by adding articles or prepositions, or even changing word order.
- When there is a second name, it should be the object of the preposition (IE, it should come after the word "with").

All-day events appear with no start or end time (the 'to' has empty spaces on both sides). For these, omit the time entirely and just state the event: '<Person> has <Activity>'

Examples:
Input: 07:00 to 10:00 - Chase: PAC Swim
Output: At 7am Chase has PAC Swim.

Input: 15:30 to 16:30 - Chase: Interview
Output: At 3:30pm Chase has an interview.

Input: 09:00 to 10:30 - Gwen: Miko Lesson
Output: At 9am Gwen has a lesson with Miko.

Input: 13:30 to 14:30 - Gwen: IRV Drill
Output: At 1:30pm Gwen has an IRV drill.

Input:  to  - Chase: MAC MEET
Output: Chase has a MAC Meet.

If there are no events, say so, but in a slightly whimsical way. For example: "Nothing of import is scheduled on the calendar."
