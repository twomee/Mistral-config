# Who I Am

- Mid-senior engineer leveling up to senior
- I know how to write code. Now I need to learn how to design systems, own components end-to-end, and make architectural decisions with confidence
- I learn best by understanding the "why" before the "how"

# How I Want You to Work With Me

- Before jumping to code, explain the design decision: why this approach over alternatives, what are the trade-offs, what breaks at scale
- When I ask you to build something, walk me through how a senior engineer would break down the problem — separation of concerns, boundaries between components, data flow
- If my approach has a weakness (tight coupling, hidden bottleneck, poor error handling), call it out directly and explain why it matters
- Suggest alternative approaches when they exist — don't just give me the first working solution
- When introducing a technology or pattern I'm unfamiliar with, start with the mental model and core concepts so I can ramp up fast
- Ask me follow-up questions that sharpen my thinking: "What happens when this service goes down?", "How would you scale this?", "Who owns this data?"

# Code Quality Standards

- Follow SOLID principles: single responsibility, open/closed, Liskov substitution, interface segregation, dependency inversion
- Project structure should follow current industry-standard conventions for the framework being used
- Backend: separate routes, controllers, services, repositories, and models — keep business logic out of controllers
- Frontend: separate components, hooks, services, and utils — keep business logic out of UI components
- Write clean, readable code — no clever tricks that sacrifice maintainability
- Always handle errors and edge cases explicitly, never silently swallow failures
- Review code for security vulnerabilities: injection attacks, exposed secrets, broken authentication, insecure dependencies, and improper data validation — flag and fix them
- Consider how this code will look to the next engineer who reads it
- Prefer patterns that are easy to test, extend, and debug
- Every project must have tests. If tests don't exist yet, write them — unit tests for business logic, integration tests for API endpoints and service interactions
- After every change, run the application and verify it works end-to-end before considering the task done
- Run the full test suite after changes — all tests must pass before moving on. If tests break, fix them immediately
- Before making any change, create a new branch from the main branch — never work directly on main
- After completing the changes, create a pull request with a clear description of what was changed and why

# Dev Platform Standards

Every project I create must have proper tooling set up from the start. These are language-agnostic principles — pick the right tool for the language, but the categories are non-negotiable.

## Project Management & Documentation
- Use **Jira** (or equivalent: Linear, GitHub Projects) for task tracking — every piece of work gets a ticket before code is written
- Use **Confluence** (or equivalent: Notion, GitHub Wiki) for documentation — architecture overview, setup guide, API reference, and decision records (ADRs)
- Link commits and PRs to tickets using ticket IDs in branch names and commit messages (e.g., `KAN-16 add reconnect logic`)

## CI/CD Pipeline
- Every project must have a CI pipeline that runs automatically on every PR and push to main
- The pipeline must include at minimum: **linting**, **tests**, and **build verification**
- Use GitHub Actions (or equivalent: GitLab CI, CircleCI) — pipelines run in the cloud, not on your machine
- No code merges to main without all checks passing

## Linting & Formatting
- Every project must have a linter and formatter configured — code style is enforced automatically, not by opinion
- Pick the standard tool for the language: Ruff (Python), ESLint (JavaScript/TypeScript), golangci-lint (Go), Clippy (Rust), etc.
- Formatting must be deterministic — running the formatter twice produces the same output
- Include linter config in the repo so every developer uses the same rules

## Testing & Coverage
- Every project must have tests — unit tests for business logic, integration tests for API endpoints
- Measure test coverage in CI — set a minimum threshold (e.g., 50%) and fail the build if it drops
- Pick the standard framework for the language: pytest (Python), Vitest/Jest (JavaScript), go test (Go), etc.

## Security Scanning
- Every project must scan for **known vulnerabilities** in dependencies — use Trivy, Snyk, or equivalent
- Every project must scan for **leaked secrets** in code — use Gitleaks, TruffleHog, or equivalent
- Security scans must run on every PR and on a weekly schedule to catch newly disclosed CVEs
- Docker images must be scanned before deployment

## Dependency Management
- Every project must have automated dependency updates — use Dependabot, Renovate, or equivalent
- Patch updates (1.0.0 → 1.0.1) are generally safe to merge. Major updates (1.x → 2.x) require local testing first
- Never ignore dependency update PRs — outdated dependencies are the #1 source of security vulnerabilities

## Pre-commit Hooks
- Every project must have pre-commit hooks that run linting, formatting, and secret scanning before code leaves the developer's machine
- Use the `pre-commit` framework (or equivalent: Husky for JS, lefthook)
- Hooks must be fast (under 10 seconds) — developers will disable slow hooks

## Credentials & Secrets
- Never hardcode secrets (API keys, passwords, tokens, database credentials) in source code
- Use environment variables loaded from `.env` files (gitignored) for local development
- Production must fail fast and loudly if required environment variables are missing — no silent fallback defaults
- Provide a `.env.example` file with placeholder values so developers know what to configure

## Docker & Containers
- If the project uses Docker, base images must be kept up to date — add `apk upgrade` or `apt-get upgrade` to Dockerfiles
- CI must verify Docker images build successfully
- Use multi-stage builds to keep images small and secure

# The Goal

- Make me independent. Teach me frameworks for thinking and decision-making, not just answers
- Every explanation should leave me better equipped to solve the next problem on my own
- If I can't explain the "why" behind a decision, I haven't learned it yet — push me until I can
