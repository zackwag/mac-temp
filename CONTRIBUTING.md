# Contributing to mac-temp

Thanks for considering a contribution to mac-temp, a native Objective-C CLI for reading CPU/thermal sensors on Apple Silicon Macs.

## Getting started

```bash
git clone https://github.com/zackwag/mac-temp.git
cd mac-temp
make
```

Requires macOS 12+ on Apple Silicon, and Xcode Command Line Tools (`xcode-select --install`).

## Development

```bash
make           # build the mac-temp binary
make install   # build and install to /usr/local/bin
make release   # build a universal (arm64 + x86_64) binary
make clean     # remove build artifacts
```

There is no automated test suite — this is a single-file (`mac-temp.m`) tool that reads hardware sensors directly via IOKit, which isn't practical to unit test in CI. Changes are verified by building and running on real Apple Silicon hardware.

## Commit messages and pull requests

This repo uses [Conventional Commits](https://www.conventionalcommits.org/) (`feat:`, `fix:`, `docs:`, `chore:`, etc.). Pull requests are squash-merged, and the **PR title** becomes the commit on `main` — so PR titles must follow this format. This is enforced automatically by the "Conventional Commits" check.

Direct pushes to `main` are allowed but must also use a Conventional Commits-formatted commit message (validated by the same check).

## Opening a pull request

1. Fork the repo and create a branch off `main`.
2. Make your changes.
3. Open a pull request with a Conventional Commits-formatted title.
4. Wait for CI to pass — required checks must be green before merge.

## Reporting issues

Use [GitHub Issues](../../issues) for bugs and feature requests.
