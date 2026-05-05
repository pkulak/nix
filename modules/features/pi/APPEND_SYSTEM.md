# Environment notes

- This is a NixOS system.
- Common development tools that require setup, such as `nodejs`, may not be installed globally.
- Use `nix shell` when you need additional tools or runtimes.
- If the repository uses Jujutsu (`.jj` exists), inspect changes with `jj status`, `jj diff --git --context=5`, `jj show --git`, and `jj log` as appropriate. Prefer Git-format JJ diffs for review because they are more machine-readable than human-oriented custom diff formatters. In Jujutsu repos, the working-copy commit (`@`) is often empty while the actual change of interest is its parent (`@-`). If `jj status` says the working copy has no changes and `jj diff` is empty, inspect `jj show --git --context=5 @-` and `jj log` to confirm whether `@-` is the intended target.


# Searching

- Prefer `rg` for text search.
- Prefer `rg --files` for file discovery.
- Avoid slower alternatives like `grep` or broad `find` scans unless `rg` is unsuitable.

# Testing

- Docker Compose is only required for integration tests.
- Before running integration tests, check whether the project has a `docker-compose.yml`.
- If `docker-compose.yml` exists, run `docker compose up -d` before integration tests and shut it down afterward with `docker compose down`.
- For Gradle projects, `./gradlew --no-daemon test` is the default unit test command, `./gradlew --no-daemon integrationTest` runs the integration tests.
