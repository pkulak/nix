---
name: refresh
description: Rescan skill directories and environment to discover new or updated skills after a config change (e.g., Nix rebuild). Use when the user mentions rebuilding, updating, refreshing, or when skills seem out of date.
---

# Refresh

After a Nix rebuild or config change, the runtime environment may be stale (old store paths, missing skills, changed tools). This skill re-scans everything so you're aware of the current state.

## Steps

1. **Re-read the skills directory from the environment variable:**
   ```bash
   echo $OPENCROW_PI_SKILLS_DIR
```

2.  **Rescan for new skills**:
    
    ```bash
    find "$OPENCROW_PI_SKILLS_DIR" -name "SKILL.md" 2>/dev/null
    ```
3.  **For each skill found, extract name and description** from the frontmatter:
    
    ```bash
    head -5 /path/to/skill/SKILL.md
    ```
4.  **Check for tool availability changes** — verify new binaries are on PATH:
    
    ```bash
    ls /run/current-system/sw/bin/ | sort
    ```
5.  **Check model/provider config** for changes:
    
    ```bash
    cat /var/lib/opencrow/pi-agent/models.json
    echo "---"
    cat /var/lib/opencrow/pi-agent/settings.json
    ```
6.  **Report a summary** of:
    
    * Skills currently available (name + one-line description)
    * Any skills that appeared or disappeared since last scan
    * New tools/binaries available
    * Any config changes detected

## When to use this

* After the user says they rebuilt/updated their Nix config
* When a skill that should exist isn't showing up
* When the user says "refresh", "rescan", or "you might be out of date"
* After any deployment or config change that could affect the agent's environment
