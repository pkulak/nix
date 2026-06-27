---
name: print
description: Print PDFs, images, Markdown files such as recipes, or web pages/URLs to the Garage CUPS printer. Use only for explicit physical printing requests.
---

# Print

Print to the CUPS printer named `Garage`.

Printing is a physical side effect. Only print when the user clearly asks to print. If the user asks to show, view, make printable, or send a PDF, do not print unless they also explicitly ask for physical printing.

Before printing, check the printer:

```bash
lpstat -p Garage -d
```

Ask for confirmation before printing if:

- the source is ambiguous,
- the printer is disabled/offline,
- a PDF is more than 10 pages,
- the user asks for multiple copies,
- special paper, color, duplex, or quality options are unclear.

Use `/tmp/print` for generated files:

```bash
mkdir -p /tmp/print
```

## Print a PDF file or attachment

OpenCrow downloads attachments into the session directory. If the user attached a PDF, use its local path.

```bash
file="/path/to/file.pdf"
pdfinfo "$file" 2>/dev/null | sed -n '1,20p'
lpstat -p Garage -d
lp -d Garage "$file"
```

`lp` prints a job id like `request id is Garage-123`. Reply with that job id and page count.

## Print an image file or attachment

For images, fit to the page unless the user requested otherwise:

```bash
file="/path/to/image.jpg"
file "$file"
lpstat -p Garage -d
lp -d Garage -o fit-to-page "$file"
```

## Print Markdown, especially recipes

Recipes are stored as Markdown, so print them directly through Pandoc using Typst as the PDF engine.

For an existing Markdown file:

```bash
in="$HOME/notes/recipes/recipe-name.md"
out="/tmp/print/recipe-name.pdf"

pandoc "$in" \
  --standalone \
  --pdf-engine=typst \
  -V papersize=us-letter \
  -V mainfont="Libertinus Serif" \
  -V margin.x=0.75in \
  -V margin.y=0.75in \
  -o "$out"

pdfinfo "$out" 2>/dev/null | sed -n '1,20p'
lpstat -p Garage -d
lp -d Garage "$out"
```

For modified output, such as halving a recipe or converting units, write the modified Markdown to `/tmp/print/recipe-name.md` first, then run the same Pandoc command on that temp file. Do not overwrite the stored recipe unless the user explicitly asks to save the modification.

## Print a web page or URL

For HTTP/HTTPS URLs, use the native `agent_browser` tool so JavaScript, cookies, and print CSS work.

1. Open the page:

```text
agent_browser args: ["open", "https://example.com/page"]
```

2. Let the page render. If needed, interact with the page to reach the printable content.
3. Save a PDF:

```text
agent_browser args: ["pdf", "/tmp/print/page.pdf"]
```

4. Check page count and print:

```bash
pdfinfo /tmp/print/page.pdf 2>/dev/null | sed -n '1,20p'
lpstat -p Garage -d
lp -d Garage /tmp/print/page.pdf
```

## Common options

Use explicit options when requested:

```bash
lp -d Garage -n 2 file.pdf                 # two copies
lp -d Garage -o sides=two-sided-long-edge file.pdf
lp -d Garage -o sides=one-sided file.pdf
lp -d Garage -o print-color-mode=monochrome file.pdf
```

The Garage default is one-sided letter paper.

## Response style

Keep the response short:

```text
Printed the cookie recipe to Garage — 2 pages. Job: Garage-123
```

If printing fails, include the useful error and do not retry repeatedly.
