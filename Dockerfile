# The runner image for Cyberun's self-hosted scale sets
# (cyberun-cloud/cyberun-stack docs/ci-runners.md).
#
# The official image is deliberately thin; our workflows were written against
# GitHub's ubuntu-latest, which ships a C toolchain (Go's -race needs cgo),
# rustup (edgewright's `rustup show` reads rust-toolchain.toml), python3,
# ruby (cyberun-stack's release contract), shellcheck, psql and gh.
# Everything a workflow installs itself through a setup-* action (Go, Node,
# pnpm) is left to that action, so versions stay owned by the repo.
FROM ghcr.io/actions/actions-runner:2.338.1

USER root
RUN apt-get update -y \
    && apt-get install -y --no-install-recommends \
       build-essential pkg-config libssl-dev ca-certificates gnupg \
       wget xz-utils zip zstd file rsync openssh-client \
       python3 python3-venv python3-pip python3-yaml \
       ruby shellcheck postgresql-client \
    && install -d -m 0755 /etc/apt/keyrings \
    && curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
       -o /etc/apt/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
       > /etc/apt/sources.list.d/github-cli.list \
    && apt-get update -y && apt-get install -y --no-install-recommends gh \
    && rm -rf /var/lib/apt/lists/*

# What `playwright install --with-deps chromium` installs on Ubuntu 24.04
# (soulhall's component tests). Fetched per job it was ~82 MB of apt, and on
# 2026-11-27 one shard took 7 min 10 s at 192 kB/s from the Ubuntu mirror.
# Baked in here, the workflow only downloads the browser itself.
RUN apt-get update -y \
    && apt-get install -y --no-install-recommends \
       libasound2t64 libatk-bridge2.0-0t64 libatk1.0-0t64 libatspi2.0-0t64 \
       libcairo2 libcups2t64 libdbus-1-3 libdrm2 libgbm1 libglib2.0-0t64 \
       libnspr4 libnss3 libpango-1.0-0 libx11-6 libxcb1 libxcomposite1 \
       libxdamage1 libxext6 libxfixes3 libxkbcommon0 libxrandr2 xvfb \
       libfontconfig1 libfreetype6 fonts-noto-color-emoji fonts-unifont \
       fonts-liberation fonts-ipafont-gothic fonts-wqy-zenhei \
       fonts-tlwg-loma-otf fonts-freefont-ttf xfonts-cyrillic xfonts-scalable \
    && rm -rf /var/lib/apt/lists/*

USER runner
# No default toolchain: each repository's rust-toolchain.toml decides.
RUN curl -fsSL https://sh.rustup.rs | sh -s -- -y --no-modify-path --default-toolchain none --profile minimal
ENV PATH=/home/runner/.cargo/bin:$PATH
