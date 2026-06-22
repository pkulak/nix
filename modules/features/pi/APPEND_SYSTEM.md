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
- Prefer built-in `find`/`ls` tools for file discovery when suitable.
- Keep broad file discovery scoped to avoid large outputs.

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
