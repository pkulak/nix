---
name: Check Low Priority Email
description: Check for new low-priority email and summarize the results. Trigger by explicitly asking to check "low priority" mail or email.
---

# Check Email

Run `getmail --mailbox "Low Priority"` and summarize the result.

## Output format

- **If no important mail:** output exactly `NO_REPLY`.
- **If one or more important emails:** output a summary of the important messages.

## What's important

This is the low priority mailbox, meaning every message here is from someone not in my contact list. Your job is to search through all of it and find anything that may be important. It is likely, however, that nothing is important, and that's okay. In that case, output 'NO_REPLY'.

