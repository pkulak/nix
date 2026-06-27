---
name: save-recipe
description: Save, recall, edit, view/print, or make a recipe from a video. Recipes may come from a URL, video URL, or pasted text.
---

# Save Recipe

Save recipes under `~/notes/recipes/` as a plain Markdown file with a short, slug-style filename.

Only save:

- the ingredient list
- the directions/instructions

# Video Sources

When the recipe comes from a video URL, use the download skill to extract only the audio. Do not upload or return the audio/video. Transcribe the audio with the transcribe skill, then turn that transcript into the normal recipe format: ingredients and directions only.

# Interpret Recipe

You may also be asked to interpret and give instructions based on the whole recipe. For example, "I'm going to start making fried chicken. Please give me instructions up to the marinade step." This means combining ingredients and instructions into merged plain-text instructions that can easily be glanced at.

# View Recipe

When asked to show, display, view, or provide a printable version of a recipe, render the recipe as very basic print-friendly HTML, write it to `/tmp/slugged-recipe-name.html`, and upload it to the public file folder. Apply any requested modifications first, such as halving, doubling, scaling servings, or converting units.

```bash
curl -T /tmp/recipe-name.html \
  -H "X-OC-Mtime: $(date +%s)" \
  https://files.kulak.us/public/recipe-name.html
```

This intentionally overwrites the existing public file (due to the X-OC-Mtime header) if one is already there. Reply with the link: https://files.kulak.us/public/recipe-name.html

Do not physically print unless the user explicitly asks to print.

# Print Recipe

When asked to print a recipe, create a PDF with Pandoc and Typst, then print it to the `Garage` CUPS printer. For an unchanged stored recipe, use the Markdown file directly. For requested modifications, such as halving, doubling, scaling servings, or converting units, write the modified recipe Markdown to `/tmp/print/recipe-name.md` first and print that temp file. Do not overwrite the stored recipe unless the user explicitly asks to save the changes.

```bash
mkdir -p /tmp/print
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

Reply with the job id from `lp` and the page count from `pdfinfo`.

# Edit Recipe

You may be asked to edit a recipe. For example, to "double the salt".
