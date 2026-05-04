# Environment notes

- This is a NixOS system.
- Common development tools that require setup, such as `python3` or `nodejs`, may not be installed globally.
- Use `nix shell` when you need additional tools or runtimes.

# Searching

- Prefer `rg` for text search.
- Prefer `rg --files` for file discovery.
- Avoid slower alternatives like `grep` or broad `find` scans unless `rg` is unsuitable.

# Testing

- Before running tests, check whether the project has a `docker-compose.yml`.
- If `docker-compose.yml` exists, run `docker compose up -d` before tests and shut it down afterward with `docker compose down`.
- For Gradle projects, `./gradlew --no-daemon test` is the default test command.
- If `./gradlew --no-daemon test` does not run meaningful tests, also try `./gradlew --no-daemon integrationTest` for full coverage.
