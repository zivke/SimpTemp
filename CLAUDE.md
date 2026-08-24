# SimpTemp

Garmin Connect IQ widget: shows temperature from the internal sensor at 0.1°
precision, charts history, min/max over a period, and current time. Some devices
need an external temperature sensor.

Everything runs in the devcontainer — SDK, simulator and developer key are
already set up. Never install or generate them.

## Commands

- `make build` / `make release` — compile for `$(DEVICE)` (default `fenix7`)
- `make sim` then `make run` — simulator must be running before `monkeydo`
- `make test` — `monkey-test.jungle` with `--unit-test`
- `make package` — `.iq` for the store; needs `make all-devices` first
- `make dev-device` — download one device's files; `make all-devices` is many GB

## Layout

- `source/` — widget code
- `resources/` — base resources, compiled into `Rez.*`
- `resources-round/`, `resources-rectangle/`, `resources-semioctagon-176x176/`,
  `resources-instinct2s/`, `resources-instincte40mm/` — layout overrides layered
  over `resources/` per shape or device. A layout change usually means touching
  several of these, not just one.
- `source-test/` — test-only, reached via `monkey-test.jungle`
- `manifest.xml` — ~90 products. Adding one means editing it, downloading the
  device, and updating the supported-devices list in `README.md`.

## Conventions

- Type checking is Strict — annotate params and returns
- User-visible text goes in the strings resources, never inline
- Never change `manifest.xml`'s `id` — it is the published app's identity
- Update `changelog.md` for anything user-visible
