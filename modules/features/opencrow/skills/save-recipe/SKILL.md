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

# Recall Recipe

You may be asked to recall directions, instructions, or both, either as recorded, or modified. For example, with the ingredients halved. For recall, use plain text, with a blank line between each ingredient or step.

You may also be asked to interpret and give instructions based on the whole recipe. For example, "I'm going to start making fried chicken. Please give me instructions up to the marinade step." This would mean combining ingredients and instructions into merged instructions that can easily be glanced at.

# View Recipe

When asked to show a recipe, print a recipe, or provide a printable view, render the recipe as very basic print-friendly HTML, write it to `./recipe.html`, and upload it to the public file folder:

```bash
curl -T ./recipe.html https://files.kulak.us/public/recipe.html
```

This intentionally overwrites the existing public file if one is already there. Reply with the link: https://files.kulak.us/public/recipe.html

# Edit Recipe

You may be asked to edit a recipe. For example, to "double the salt".
