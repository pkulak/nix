---
name: Check Email
description: Check for new email via the `getmail` command and summarize any messages found. Use whenever the user asks to check mail, check email, see new messages, or check the inbox — even if they don't mention `getmail` by name.
---

# Check Email

Run `getmail` and summarize the result.

## Output format

- **If no mail:** output exactly `HEARTBEAT_OK` and nothing else.
- **If one or more emails:** output a one-sentence summary of each email, one per line, with no blank lines between them. No preamble, no closing remarks, no other text. Keep each summary tight — only the most important details.

## Special case: Team Privacy

If the sender is Team Privacy (`support@privacy.com`), the summary for that message must be exactly:

> `<amount> was <authorized or declined> at <location> on your <card name> card.`

Fill in the four fields from the email contents. This is the entire summary for that message — don't add anything else.

## Example

Input: two emails, one from Alice about lunch plans and one from Team Privacy about a declined charge.

Output:
```
Alice wants to grab lunch Thursday at noon.
$47.22 was declined at Trader Joe's on your Sapphire card.
```
