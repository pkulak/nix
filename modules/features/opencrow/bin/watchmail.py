import imaplib, os, re, sys, time

PIPE = os.environ.get('OPENCROW_TRIGGER_PIPE', '/var/lib/opencrow/sessions/trigger.pipe')
HOST = 'imap.fastmail.com'
USER = 'phil@kulak.us'
PASS = os.environ["OPENCROW_IMAP_PASSWORD"]

if len(sys.argv) < 2:
    sys.exit('usage: watchmail MESSAGE')
message = ' '.join(sys.argv[1:])

def write_pipe(msg):
    try:
        fd = os.open(PIPE, os.O_WRONLY | os.O_NONBLOCK)
    except FileNotFoundError:
        print(f'watchmail: pipe not found: {PIPE}', file=sys.stderr)
        return False
    except BlockingIOError:
        print('watchmail: no reader on pipe, skipping', file=sys.stderr)
        return False
    try:
        os.write(fd, (msg + '\n').encode())
    finally:
        os.close(fd)
    return True

def get_uidnext(conn):
    _, data = conn.status('INBOX', '(UIDNEXT)')
    return int(re.search(r'UIDNEXT (\d+)', data[0].decode()).group(1))

def connect():
    conn = imaplib.IMAP4_SSL(HOST)
    conn.login(USER, PASS)
    return conn

conn = None
last_uidnext = None
while True:
    try:
        if conn is None:
            conn = connect()
        uidnext = get_uidnext(conn)
        if last_uidnext is None:
            # First check: record baseline without triggering
            last_uidnext = uidnext
            print(f'watchmail: baseline UIDNEXT={uidnext}', file=sys.stderr)
        elif uidnext > last_uidnext:
            print(f'watchmail: new mail (UIDNEXT {last_uidnext} -> {uidnext})', file=sys.stderr)
            if write_pipe(message):
                last_uidnext = uidnext
    except Exception as e:
        print(f'watchmail: {e}', file=sys.stderr)
        try: conn.logout()
        except: pass
        conn = None

    time.sleep(60)
