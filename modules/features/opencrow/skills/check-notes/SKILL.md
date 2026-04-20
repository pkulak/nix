---
name: check-notes
description: User asks to search notes, check notes, or look something up ("check my notes about X", "what did I write about Y", "search notes for Z"). Can be used to find a note to append to or modify.
---

**Action:**
1. Run both searches to find relevant files:
   - `rg --files-with-matches -i "<search term>" ~/notes --max-count=10 --type md 2>/dev/null`
   - `find ~/notes -iname "*<search term>*" -type f 2>/dev/null | head -10`
2. Combine results (deduplicate if needed)
3. Read the files into context
4. Answer the question based on the content

If no files match, tell the user nothing was found.

**Show All Files**
If you need to find the right file to append to or modify, and search doesn't return anything, you can use the following command (to avoid listing irrelevant files):

find ~/notes/ -type f -not -path '*/notes/daily/*' -not -path '*/notes/private/*' -not -path '*/.git/*'
