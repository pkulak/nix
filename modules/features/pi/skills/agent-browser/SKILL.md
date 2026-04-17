---
name: agent-browser
description: Browser automation using agent-browser CLI. Navigate pages, interact with elements via accessibility refs, take screenshots, extract text, manage tabs, handle auth, and more. Also used for documentation lookup when needed. For web searches, always use the private search engine via KAGI_LINK.
---

# Agent Browser Skill

Automate the browser with `agent-browser`, a fast CLI for AI agents powered by Playwright.

## Web Searches — Use Kagi

When you need to **search the web**, do not navigate to google.com or any public search engine. Instead:

1. Read the `KAGI_LINK` environment variable — it contains the URL to a private search engine.
2. Open that URL with `agent-browser open`, replacing the `%s` parameter with the search term (url escaped).
3. Use the search interface to find what you need.

## Documentation Lookup

When you need to look up documentation (API references, language docs, library specs, etc.), use this skill to navigate to the relevant docs page and extract the content you need.

## Quick Start

```bash
# Open a page and take an accessibility snapshot to understand the page
agent-browser open https://example.com && agent-browser snapshot

# Interact using refs from the snapshot (@e1, @e2, etc.)
agent-browser click @e2
agent-browser fill @e3 "test@example.com"

# Get content
agent-browser get text @e1        # Text of an element
agent-browser screenshot page.png  # Screenshot to file

# Clean up when done
agent-browser close
```

## Core Workflow

1. **Open** a URL with `agent-browser open <url>`
2. **Wait** for the page to load if needed: `agent-browser wait --load networkidle`
3. **Snapshot** to get the accessibility tree with element refs: `agent-browser snapshot`
4. **Interact** using refs from the snapshot (`@e1`, `@e2`, etc.)
5. **Extract** data with `get text`, `screenshot`, etc.
6. **Close** when finished: `agent-browser close`

Commands can be chained with `&&` since the browser persists via a daemon:

```bash
agent-browser open https://example.com && agent-browser wait --load networkidle && agent-browser snapshot -i
```

## Navigation

| Command | Description |
|---------|-------------|
| `agent-browser open <url>` | Navigate to URL |
| `agent-browser back` | Go back |
| `agent-browser forward` | Go forward |
| `agent-browser reload` | Reload page |

## Snapshot (Accessibility Tree)

The snapshot command returns an accessibility tree with element refs (`@e1`, `@e2`, …) used by all interaction commands.

```bash
agent-browser snapshot                # Full accessibility tree
agent-browser snapshot -i             # Interactive elements only
agent-browser snapshot -c             # Compact (remove empty structural elements)
agent-browser snapshot -d 3           # Limit tree depth
agent-browser snapshot -s ".main"     # Scope to CSS selector
```

**Always snapshot before interacting** to get fresh refs.

## Element Interaction

### Click, Type, Fill

```bash
agent-browser click @e1               # Click element
agent-browser dblclick @e1            # Double-click element
agent-browser fill @e1 "hello"        # Clear field then type text
agent-browser type @e1 "hello"        # Type text (appends, no clear)
agent-browser press Enter             # Press key (Enter, Tab, Control+a, etc.)
```

### Hover, Focus, Drag

```bash
agent-browser hover @e1               # Hover over element
agent-browser focus @e1               # Focus element
agent-browser drag @e1 @e2           # Drag source to destination
```

### Checkboxes, Dropdowns, File Upload

```bash
agent-browser check @e1              # Check a checkbox
agent-browser uncheck @e1            # Uncheck a checkbox
agent-browser select @e1 "Option"    # Select dropdown option
agent-browser upload @e1 file.png    # Upload file(s)
agent-browser download @e1 output/    # Download file by clicking element
```

### Keyboard (No Selector)

```bash
agent-browser keyboard type "hello"         # Type text with real keystrokes
agent-browser keyboard inserttext "hello"   # Insert text without key events
```

### Scrolling

```bash
agent-browser scroll down             # Scroll down (up/down/left/right)
agent-browser scroll down 500         # Scroll specific pixels
agent-browser scrollintoview @e1      # Scroll element into view
```

## Waiting

```bash
agent-browser wait @e1                # Wait for element to appear
agent-browser wait 3000               # Wait 3 seconds
agent-browser wait --load networkidle # Wait for network idle
agent-browser wait --load domcontentloaded  # Wait for DOM content loaded
```

## Extract Data

### Get Text, HTML, Attributes

```bash
agent-browser get text @e1           # Text content of element
agent-browser get html @e1           # HTML content of element
agent-browser get value @e1           # Input value
agent-browser get attr href @e1        # Get attribute value
agent-browser get title                # Page title
agent-browser get url                  # Current URL
agent-browser get count "div.item"     # Count matching elements
agent-browser get box @e1              # Bounding box
agent-browser get styles @e1           # Computed styles
```

### Screenshots

```bash
agent-browser screenshot page.png                    # Save screenshot
agent-browser screenshot --full page.png             # Full page screenshot
agent-browser screenshot --annotate page.png         # Labeled with numbered elements
```

### PDF

```bash
agent-browser pdf page.pdf           # Save current page as PDF
```

## Find Elements

Locate elements by ARIA role, text, label, placeholder, alt text, title, or test ID:

```bash
agent-browser find role button click --name Submit    # Find button by role, click it
agent-browser find text "Login" click                 # Find by text content
agent-browser find label "Email" fill "a@b.com"       # Find by label, fill it
agent-browser find placeholder "Search" type "query"   # Find by placeholder
agent-browser find alt "Logo" click                    # Find by alt text
agent-browser find testid "submit-btn" click           # Find by test ID
```

Append `first`, `last`, or `nth <n>` to disambiguate:

```bash
agent-browser find role link first click
agent-browser find role link nth 2 click
```

## Check State

```bash
agent-browser is visible @e1       # Is element visible?
agent-browser is enabled @e1       # Is element enabled?
agent-browser is checked @e1       # Is checkbox checked?
```

## Tabs

```bash
agent-browser tab new                # Open new tab
agent-browser tab list               # List all tabs
agent-browser tab close              # Close current tab
agent-browser tab 2                  # Switch to tab by number
```

## Authentication

### Persistent Profiles

Reuse login sessions across restarts:

```bash
agent-browser --profile ~/.myapp open https://example.com
```

### Session State

Auto-save/restore cookies and localStorage:

```bash
agent-browser --session-name myapp open https://example.com
```

### Auth Vault

Save and reuse login credentials:

```bash
agent-browser auth save github --url https://github.com --username user --password pass
agent-browser auth login github     # Auto-fills login form
agent-browser auth list              # List saved profiles
agent-browser auth show github       # Show profile metadata
agent-browser auth delete github     # Delete profile
```

### Saved State File

```bash
agent-browser --state ./auth.json open https://example.com          # Load saved state
agent-browser --auto-connect state save ./auth.json                  # Save state from running Chrome
```

## Network

### Route Interception

```bash
agent-browser network route "https://api.example.com/*"                    # Block matching requests
agent-browser network route "https://api.example.com/*" --body '{"ok":true}'  # Mock response
agent-browser network unroute "https://api.example.com/*"                  # Remove route
```

### Request Logging

```bash
agent-browser network requests                    # List intercepted requests
agent-browser network requests --filter "api"     # Filter by pattern
agent-browser network requests --clear             # Clear request log
```

### HAR Recording

```bash
agent-browser network har start                   # Start recording
agent-browser network har stop recording.har      # Stop and save
```

## Storage

### Cookies

```bash
agent-browser cookies get                          # Get all cookies
agent-browser cookies set --url "https://example.com" --name "foo" --value "bar"
agent-browser cookies clear                        # Clear cookies
```

### Web Storage

```bash
agent-browser storage local                        # LocalStorage
agent-browser storage session                       # SessionStorage
```

## Diff

Compare page states:

```bash
agent-browser diff snapshot                         # Compare current vs last snapshot
agent-browser diff screenshot --baseline           # Compare current vs baseline image
agent-browser diff url https://a.com https://b.com # Compare two pages
```

## Debug

```bash
agent-browser highlight @e1         # Highlight element visually
agent-browser console                # View console logs
agent-browser console --clear        # Clear console
agent-browser errors                 # View page errors
agent-browser errors --clear         # Clear errors
agent-browser inspect                # Open Chrome DevTools
```

## Video & Tracing

```bash
agent-browser record start video.webm https://example.com  # Start recording
agent-browser record stop                                    # Stop recording

agent-browser trace start                    # Start trace
agent-browser trace stop ./traces/          # Stop and save trace

agent-browser profiler start                # Start profiler
agent-browser profiler stop ./profiles/     # Stop and save profile
```

## Batch Mode

Execute multiple commands from a JSON array:

```bash
echo '[["open","https://example.com"],["snapshot"],["click","@e1"],["screenshot","result.png"]]' | agent-browser batch
echo '[["open","https://example.com"],["fill","@e1","test"]]' | agent-browser batch --bail  # Stop on error
```

## Streaming

```bash
agent-browser stream enable           # Start WebSocket streaming (auto port)
agent-browser stream enable --port 9999  # Specific port
agent-browser stream status           # Check streaming status
agent-browser stream disable          # Stop streaming
```

## Browser Settings

```bash
agent-browser set viewport 1280 720        # Set viewport size
agent-browser set device "iPhone 15 Pro"   # Use device presets
agent-browser set geo 37.7749 -122.4194   # Set geolocation
agent-browser set offline on              # Toggle offline mode
agent-browser set headers '{"Authorization":"Bearer token"}'  # Set custom headers
agent-browser set media dark              # Set color scheme
```

## Clipboard

```bash
agent-browser clipboard read          # Read clipboard
agent-browser clipboard write "text"  # Write to clipboard
agent-browser clipboard copy          # Copy selected text
agent-browser clipboard paste          # Paste from clipboard
```

## JavaScript Evaluation

```bash
agent-browser eval "document.title"
agent-browser eval "Array.from(document.querySelectorAll('.item')).map(e => e.textContent)"
```

## Provider Configuration

Connect to a remote browser provider:

```bash
agent-browser -p browserless open https://example.com   # Browserless
agent-browser -p browserbase open https://example.com   # Browserbase
agent-browser -p kernel open https://example.com         # Kernel
agent-browser -p browseruse open https://example.com    # BrowserUse
agent-browser -p ios open https://example.com           # iOS Simulator
agent-browser --cdp 9222 snapshot                        # Connect via CDP port
agent-browser --auto-connect snapshot                   # Auto-discover running Chrome
```

## Common Patterns

### Fill a login form and submit

```bash
agent-browser open https://example.com/login && \
agent-browser snapshot -i && \
agent-browser fill @e1 "user@example.com" && \
agent-browser fill @e2 "password123" && \
agent-browser click @e3
```

### Scrape a page with waits

```bash
agent-browser open https://example.com && \
agent-browser wait --load networkidle && \
agent-browser snapshot && \
agent-browser get text "article"
```

### Take annotated screenshot for vision model

```bash
agent-browser open https://example.com && \
agent-browser wait --load networkidle && \
agent-browser screenshot --annotate page.png
```

### Handle paginated content

```bash
agent-browser open https://example.com/list && \
agent-browser snapshot -i && \
agent-browser click @next && \
agent-browser wait --load networkidle
```

## Tips

- **Always snapshot before interacting** — refs change after any page modification
- **Chain commands with `&&`** — avoids daemon connection overhead between calls
- **Use `snapshot -i`** for interactive elements only — much shorter output for form-heavy pages
- **Use `wait --load networkidle`** after opening pages that load dynamically
- **Use `--profile`** to persist login sessions across browser restarts
- **Use `--session-name`** for automatic state save/restore without managing files
- **Use `close --all`** to clean up all browser sessions when finished
