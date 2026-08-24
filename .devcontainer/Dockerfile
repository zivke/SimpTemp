# Same devcontainers base family you use, pinned to 22.04 rather than 24.04:
# Garmin's simulator and SDK Manager still link libwebkit2gtk-4.0.so.37 and
# libjavascriptcoregtk-4.0.so.18, which Ubuntu dropped after jammy. Everything
# else (vscode user, sudo, git, common-utils) comes from the base image.
FROM mcr.microsoft.com/devcontainers/base:ubuntu-22.04

ARG DEBIAN_FRONTEND=noninteractive

# JRE (monkeyc/monkeydo are Java) + simulator runtime deps
RUN apt-get update && apt-get install -y --no-install-recommends \
      openjdk-17-jre-headless \
      libwebkit2gtk-4.0-37 libjavascriptcoregtk-4.0-18 \
      libgtk-3-0 libglib2.0-0 libgdk-pixbuf2.0-0 \
      libusb-1.0-0 libpng16-16 libjpeg8 libcurl4 libnss3 \
      libx11-6 libxi6 libxrandr2 libxcursor1 libxdamage1 libxcomposite1 \
      libxtst6 libxkbcommon0 libasound2 libgl1 libegl1 libsm6 \
      fonts-dejavu-core \
    && rm -rf /var/lib/apt/lists/*

# Headless SDK manager (Go binary) — Garmin's own sdkmanager is GUI-only.
# Pin instead with:  sh -s -- -b /usr/local/bin -d v1.6.0
RUN curl -fsSL https://raw.githubusercontent.com/lindell/connect-iq-sdk-manager-cli/master/install.sh \
      | sh -s -- -b /usr/local/bin \
    && connect-iq-sdk-manager --help >/dev/null

USER vscode
