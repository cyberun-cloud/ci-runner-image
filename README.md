# ci-runner-image

The container image for Cyberun's self-hosted GitHub Actions runners (ARC runner scale sets).

It is the official [`ghcr.io/actions/actions-runner`](https://github.com/actions/runner) plus what our workflows took for granted on GitHub's `ubuntu-latest`: a C toolchain (Go's `-race` needs cgo), rustup with no default toolchain (each repository's `rust-toolchain.toml` decides), ruby, python3 with PyYAML, shellcheck, psql and gh. Language toolchains a workflow installs through a `setup-*` action (Go, Node, pnpm) are left to that action.

Published as `ghcr.io/cyberun-cloud/ci-runner:<yyyymmdd>-<sha>` (and `latest`) on every push to `main` and weekly, so Ubuntu security updates land without a change here. Deployments pin a dated tag or digest; `latest` is for looking, not for pinning.

The image holds no credentials. Where and how it runs: `cyberun-cloud/cyberun-stack` `docs/ci-runners.md`.

A job failing with `command not found` on the self-hosted runners means a tool is missing here: add it to the `apt-get install` list and to the smoke test in `.github/workflows/build.yaml`.
