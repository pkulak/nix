---
name: check-email
description: Check for new email via the `getmail` command and summarize any messages found. Use whenever the user asks to check mail, check email, see new messages, or check the inbox.
---

# Check Email

Run `getmail` and summarize the result.

## Output format

- **If no mail:** output exactly `NO_REPLY`.
- **If one or more emails:** output a one-sentence summary of each email, one per line, with no blank lines between them. No preamble, no closing remarks, no other text. Keep each summary tight — only the most important details.

## Special case: Team Privacy

If the sender is Team Privacy (`support@privacy.com`), first pull these four fields from the email:

- **amount** (e.g. `$4.99`)
- **status** — `authorized` or `declined`
- **location** (e.g. `ALBERTSONS #0575`)
- **card name** (e.g. `Chase`, `Charlie`, `Sapphire`)

### Auto-debit (Chase and Charlie cards only)

If the card is **Chase** or **Charlie** *and* the charge was **authorized**, debit it automatically with the money skill instead of leaving it for the user to do by hand. Map the card to its user — `Chase` → `chase`, `Charlie` → `charlie` — and run:

```text
money transfer <chase or charlie> dad <amount> "<location>"
```

- Drop the leading `$` from the amount (e.g. `$4.99` → `4.99`).
- Always quote the location — it usually contains a `#`, which bash treats as the start of a comment otherwise.

For example, `$4.99 was authorized at ALBERTSONS #0575 on your Chase card.` becomes:

```text
money transfer chase dad 4.99 "ALBERTSONS #0575"
```

Once the transfer succeeds, produce **no summary line** for that message — omit it entirely. The money bot already announces it in the Bank room, so there's nothing more to report. (If auto-debited charges are the only mail, the whole output is `NO_REPLY`.)

If the transfer command fails, fall back to the normal summary below and append the failure reason, so a failed debit is never silent.

### Everything else

For **declined** charges, or **any other card**, do not transfer anything. Summarize the message as exactly:

> `<amount> was <authorized or declined> at <location> on your <card name> card.`

This is the entire summary for that message — don't add anything else.

## Example

Input: three emails — one from Alice about lunch plans, one from Team Privacy about a declined Sapphire charge, and one from Team Privacy about an authorized Chase charge.

For the authorized Chase charge, run the transfer (which produces no output line of its own):

```text
money transfer chase dad 4.99 "ALBERTSONS #0575"
```

Output (note the Chase charge is absent — it was auto-debited):
```
Alice wants to grab lunch Thursday at noon.
$47.22 was declined at Trader Joe's on your Sapphire card.
```
