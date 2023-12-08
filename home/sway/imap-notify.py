#!/usr/bin/env python

import collections
import os
import subprocess
from typing import Dict, Optional

from jmapc import Client, Ref, TypeState, MailboxQueryFilterCondition
from jmapc.methods import EmailChanges, EmailGet, EmailGetResponse, MailboxQuery

token = open('/run/agenix/jmap-secrets').read().strip()

# Create and configure client
client = Client.create_with_api_token(host="api.fastmail.com", api_token=token)

# Figure out the Inbox id
res = client.request([MailboxQuery(filter=MailboxQueryFilterCondition(name="Inbox"))])[0]
inbox_id = res.response.ids[0]
print(f"inbox id is {inbox_id}")

# Create a callback for email state changes
def email_change_callback(
    prev_state: Optional[str], new_state: Optional[str]
) -> None:
    if not prev_state or not new_state:
        return

    results = client.request(
        [EmailChanges(since_state=prev_state), EmailGet(ids=Ref("/created"))]
    )

    email_get_response = results[1].response
    assert isinstance(email_get_response, EmailGetResponse)

    for new_email in email_get_response.data:
        if new_email.mailbox_ids.get(inbox_id, False):
            subprocess.Popen(['notify-send', new_email.subject])

# Listen for events from the EventSource endpoint
all_prev_state: Dict[str, TypeState] = collections.defaultdict(TypeState)
for i, event in enumerate(client.events):
    for account_id, new_state in event.data.changed.items():
        prev_state = all_prev_state[account_id]
        if new_state != prev_state:
            if prev_state.email != new_state.email:
                email_change_callback(prev_state.email, new_state.email)
            all_prev_state[account_id] = new_state

