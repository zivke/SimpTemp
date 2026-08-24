# Devcontainer

VS Code devcontainer for SimpTemp: Connect IQ SDK, simulator, and Claude Code,
none of it installed on the host.

## Before the first build: your developer key

SimpTemp is published, so the store only accepts updates signed with the key it
was originally published with. `post-create.sh` generates a key when the
`ciq-keys` volume is empty — useful for a new app, wrong for this one. Seed the
volume with your existing key first:

```
docker volume create ciq-keys
docker run --rm -v ciq-keys:/k -v "$HOME/<dir-with-your-key>":/src:ro \
  alpine sh -c 'cp /src/developer_key.der /src/developer_key.pem /k/'
```

If you skip this, post-create prints a warning and you can fix it afterwards —
just delete the generated pair from the volume before building anything you
intend to publish.

## Why Ubuntu 22.04

Garmin's simulator and SDK Manager still link `libwebkit2gtk-4.0.so.37` and
`libjavascriptcoregtk-4.0.so.18`. Ubuntu dropped those after jammy and Debian
after 12, so a modern host can't run them without repo pinning. The container
solves that without touching the host.

The GUI `sdkmanager` is replaced by
[connect-iq-sdk-manager-cli](https://github.com/lindell/connect-iq-sdk-manager-cli),
which writes into the same `~/.Garmin/ConnectIQ` layout (`current-sdk.cfg`) that
the Garmin VS Code extension reads.

## First run

1. Host: `xhost +local:` so the simulator window can reach your X server.
2. Reopen in container.
3. In the container terminal:

   ```
   connect-iq-sdk-manager agreement view
   connect-iq-sdk-manager agreement accept
   connect-iq-sdk-manager login
   connect-iq-sdk-manager sdk set 8.2.1
   make dev-device        # just fenix7 — NOT the full manifest
   make sdk-link
   ```

4. `make build && make sim && make run`.
5. `claude` — browser OAuth once per devcontainer. After that it auto-starts.

`manifest.xml` lists ~90 products. `make all-devices` downloads every one of
them (many GB) and is only needed before `make package`; day to day use
`make dev-device` for whatever you're testing on.

## Volumes

| Volume                            | Mount                       | Holds                                 |
|-----------------------------------|-----------------------------|---------------------------------------|
| `claude-config-${devcontainerId}` | `~/.claude`                 | Claude Code auth, settings, sessions  |
| `ciq-sdk`                         | `~/.Garmin`                 | SDKs, device definitions, fonts (GBs) |
| `ciq-sdkmanager`                  | `~/.connect-iq-sdk-manager` | Garmin auth token, agreement          |
| `ciq-keys`                        | `~/.ciq`                    | developer key                         |

The three `ciq-*` volumes use fixed names on purpose — the SDK is multi-GB and
the developer key is one identity, so every Garmin project of yours shares them.
Claude's volume is `${devcontainerId}`-scoped, so sessions stay per project.

## Claude Code

- **Auto-start**: `.vscode/tasks.json` has a `folderOpen` task running
  `claude --continue`, so opening the project resumes the last session for
  `/workspace`. Sessions are keyed by directory and stored under
  `CLAUDE_CONFIG_DIR`, both of which are stable here. `--continue` exits 1 with
  no prior session, hence the `|| claude` fallback. Drop `runOptions` from the
  task to make it manual.
  This has to be a task, not `postStartCommand` — lifecycle commands run
  without a TTY and the Claude Code interface needs one.
- **Updates** run on three tracks: the built-in background updater, `claude
  update` in `postStartCommand` on every container start, and a fresh install on
  rebuild. `CLAUDE_CHANNEL` (`latest` or `stable`) sets the auto-update channel.
  `claude doctor` shows the last update attempt. Don't set `DISABLE_AUTOUPDATER`.
- **Permissions** are in `.claude/settings.json`: `Bash(*)` allowed, with the
  developer key and `git push` denied. The container is the real boundary.

## Troubleshooting

- **Simulator won't open**: check `DISPLAY` reached the container and
  `/tmp/.X11-unix` is mounted. Missing library:
  `ldd "$(connect-iq-sdk-manager sdk current-path --bin)/simulator" | grep 'not found'`
  and add the package to the Dockerfile.
- **Java**: JRE 17 is installed. If `monkeyc` throws a Java error, install
  `openjdk-11-jre-headless` and repoint `monkeyC.javaPath`.
- **SDK not on PATH**: `~/.local/ciq-sdk` is a symlink to the version-stamped SDK
  directory. Run `make sdk-link` after changing SDK versions.
- **Sideloading**: the watch mounts as USB mass storage on the *host*; copy the
  `.prg` to `GARMIN/APPS/` from there.
