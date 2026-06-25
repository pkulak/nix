# Environment notes

- This is a NixOS system.
- Common development tools that require setup, such as `nodejs`, may not be installed globally.
- Use `nix shell` when you need additional tools or runtimes.

# Web searches

- When you need to search the web, use the private Kagi search URL from the `KAGI_LINK` environment variable instead of Google or other public search engines. Replace the `%s` placeholder in `KAGI_LINK` with the URL-escaped search query, then open that URL with the native `agent_browser` tool.

# Browser automation

- For `agent_browser` `get`: only `get title` and `get url` are selectorless. Never call `get text` bare; use `get text <selector>` such as `body`, `main`, or a current `@eN` ref, or use `eval --stdin` with `document.body.innerText` for whole-page text.

# Searching

- Prefer `rg` for text search.
- Prefer `rg --files` for file discovery.
- Avoid slower alternatives like `grep` or broad `find` scans unless `rg` is unsuitable.

# RTK usage

- Prefer RTK whenever it can safely reduce high-volume read-only output; saving context is valuable.
- Use RTK by default for these eligible command categories when exact formatting is not required:
  - Large diffs: `git diff ... | rtk diff -`, `jj diff --git ... | rtk diff -`, or `jj show --git <rev> | rtk diff -`.
  - Broad VCS history: prefer scoped `jj log`/`git log` commands first; pipe large read-only history to `rtk log` when you only need an overview.
  - Large logs: `rtk log <file>` or `<log command> | rtk log`. For remote logs, pipe on the local side: `ssh host 'journalctl ...' | rtk log`.
  - Broad exploratory searches with many expected matches or long lines: use `rtk grep <pattern> <path> ...` for simple searches, or `rg ... | rtk pipe -f grep` for complex pipelines. Keep targeted searches raw.
  - Verbose builds/tests/lints: use the specific wrapper when available (`rtk gradlew ...`, `rtk cargo ...`, `rtk go test ...`, `rtk pytest ...`, `rtk npm ...`, `rtk pnpm ...`, `rtk npx ...`, `rtk tsc ...`, `rtk lint ...`) or fall back to `rtk test ...` / `rtk err ...`.
  - Docker output: `rtk docker build ...`, `rtk docker compose ...`, `rtk docker logs ...`, or `docker ... 2>&1 | rtk log`.
  - Large HTTP/JSON/API output: `rtk curl ...`, `rtk json <file>`, or pipe arbitrary command output through `rtk log` when shape/errors matter more than exact payload.
- If an eligible command might produce a lot of output, start with RTK and rerun raw only when needed.
- Do not use RTK for normal targeted search or file discovery. Use raw `rg`, `rg --files`, `grep`, `find`, `ls`, and built-in tools for exact paths and small outputs.
- If RTK hides needed context, rerun the raw command scoped to the relevant file, test, or log range.
- Never rely on RTK output for exact text replacement; use `read` or raw/path-scoped commands when exact whitespace/context matters.

# Testing in ~/vevo

- Docker Compose is only required for integration tests.
- Before running integration tests, check whether the project has a `docker-compose.yml`.
- If `docker-compose.yml` exists, run `docker compose up -d` before integration tests and shut it down afterward with `docker compose down`.
- For Gradle projects, `./gradlew --no-daemon test` is the default unit test command, `./gradlew --no-daemon integrationTest` runs the integration tests.
- Most tests are integration tests. If you want a test to run, make sure you check which kind it is and run the appropriate group. Integration tests _do not_ run by default.

# Code Style

Minimize code. Maximize fit.

Solve exactly the requested problem with the smallest maintainable change.
Do not add capabilities, options, abstractions, or refactors that were not requested.
Less code that fully solves the problem is usually better than more code that also solves it.
When in doubt, leave a short note about possible future improvements rather than implementing them.
