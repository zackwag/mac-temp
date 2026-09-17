# AGENTS.md

## Project overview

mac-temp is a native Objective-C CLI tool that reads CPU/thermal sensor temperatures on Apple Silicon Macs directly from the PMU via IOKit's private `IOHIDEventSystem` API. No dependencies.

## Setup

Requires Xcode Command Line Tools (`xcode-select --install`) on an Apple Silicon Mac running macOS 12+. No package manager dependencies.

## Build / Run

```bash
make              # builds ./mac-temp
./mac-temp        # human-readable output
./mac-temp --json # JSON output
./mac-temp --raw  # single number in °C, pipe-friendly
make install      # build + copy to /usr/local/bin
make release      # universal arm64+x86_64 binary via lipo
```

## Test

No automated test suite exists — this tool reads live hardware sensors via IOKit, which isn't practical to unit test in CI. Verify changes by building and running `make && ./mac-temp` on real Apple Silicon hardware.

## Repository structure

- `mac-temp.m` — the entire tool (single Objective-C source file)
- `Makefile` — build/install/release targets

## Commit and PR conventions

- Commit messages and PR titles must follow [Conventional Commits](https://www.conventionalcommits.org/) (`feat:`, `fix:`, `docs:`, `chore:`, `refactor:`, `test:`, `ci:`, `build:`, `perf:`, `style:`, `revert:`), optionally with a scope, e.g. `fix(api): handle null response`.
- This repo squash-merges pull requests only; the PR title becomes the final commit message on `main`.
- A "Conventional Commits" CI check enforces this on both PR titles and direct-push commit messages.
- Branch protection on `main`: no force-pushes, no branch deletion, required status checks must pass.
