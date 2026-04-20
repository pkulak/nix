#!/usr/bin/env python3
import imaplib, email, json, os, sys, argparse, textwrap
from bs4 import BeautifulSoup

SEEN_DIR = '/var/lib/opencrow/pi-agent/mailcheck'
SEEN_FILE = os.path.join(SEEN_DIR, 'seen.json')
SEEN_LIMIT = 2056

def load_seen():
    if os.path.exists(SEEN_FILE):
        with open(SEEN_FILE) as f:
            return json.load(f)
    return []

def save_seen(seen):
    os.makedirs(SEEN_DIR, exist_ok=True)
    with open(SEEN_FILE, 'w') as f:
        json.dump(seen[-SEEN_LIMIT:], f)

def get_body(msg):
    plain = None
    html = None

    if msg.is_multipart():
        for part in msg.walk():
            ct = part.get_content_type()
            if ct == 'text/plain' and plain is None:
                plain = part.get_payload(decode=True).decode(errors='replace')
            elif ct == 'text/html' and html is None:
                html = part.get_payload(decode=True).decode(errors='replace')
    else:
        ct = msg.get_content_type()
        if ct == 'text/plain':
            plain = msg.get_payload(decode=True).decode(errors='replace')
        elif ct == 'text/html':
            html = msg.get_payload(decode=True).decode(errors='replace')

    if plain:
        return plain[:1024]
    if html:
        return BeautifulSoup(html, 'html.parser').get_text()[:1024]

    return ''

# --- config ---
HOST = 'imap.fastmail.com'
USER = 'phil@kulak.us'
PASS = os.environ["OPENCROW_IMAP_PASSWORD"]
# --------------

parser = argparse.ArgumentParser(description='Check for new mail.')
parser.add_argument('-m', '--mailbox', default='INBOX',
                    help='IMAP mailbox to check (default: INBOX)')
args = parser.parse_args()

seen = load_seen()
seen_set = set(seen)

conn = imaplib.IMAP4_SSL(HOST)
conn.login(USER, PASS)
conn.select(f'"{args.mailbox}"', readonly=True)

_, ids = conn.search(None, 'ALL')
new_count = 0

for mid in ids[0].split():
    _, data = conn.fetch(mid, '(RFC822)')
    msg = email.message_from_bytes(data[0][1])
    msg_id = msg['message-id']

    if not msg_id or msg_id in seen_set:
        continue

    print(f"From:    {msg['from']}")
    print(f"Date:    {msg['date']}")
    print(f"Subject: {msg['subject']}")
    print('-' * 60)
    print(textwrap.fill(get_body(msg).strip(), width=80))
    print('=' * 60)
    print()

    seen.append(msg_id)
    new_count += 1

save_seen(seen)
conn.logout()

if new_count == 0:
    print('No new mail.')
