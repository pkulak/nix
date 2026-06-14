---
name: money
description: Check balances, transfer money between household members, and reverse the last transaction using the family bank. Use when asked how much money someone has, to send/give/transfer money, pay an allowance, undo/reverse a transfer, etc.
---

# Money

Use bash to run the `money` command.

## Check a balance

```text
money balance <user>
```

Prints the user's current balance, e.g. `$50.00`. The user can be a first name
(`charlie`), or `dad`/`mom`.

## Transfer money

```text
money transfer <from> <to> <amount> [memo...]
```

Sends `<amount>` (in dollars, e.g. `5` or `5.00`) from one user to another, and
notes it in the Bank room. The memo is optional and may be several words.

```text
money transfer dad charlie 5.00 weekly allowance
```

## Reverse the last transaction

```text
money reverse
```

Reverses the most recent transaction by adding a new transaction in the opposite
direction, and notes it in the Bank room.

## Notes

- Names resolve the same way as the chat bot: bare first names, plus `dad` and `mom`.
- Amounts are dollars, not cents.
- A failed command prints the reason (e.g. an invalid amount) and exits non-zero.
