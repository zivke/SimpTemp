# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.3.1] - 2025-03-08

### Changed

- Refresh the screen on 30 seconds (down from 60 seconds)
- Refine the temperature fetching errors even more

### Fixed

- Fix the drawing of unavailable data (shorted the chart to 6 maximum hours)
- Fix the drawing of the hour marks on the chart

## [1.3.0] - 2025-03-05

### Added

- Process all known errors and act accordingly

### Changed

- Restyle the glance view
- Completely redo the info/error reporting
- Speed up the initial view transition
- Speed up the glance view loading

### Fixed
  
- Eliminate as many failing points as possible to reduce the chances of a crash
- Fix the icon issues on various devices
- Remove Approach S50 from supported devices

## [1.2.1] - 2025-02-28

### Fixed

- Sometimes the temperature timestamp can be out of temperature history range

## [1.2.0] - 2025-02-28

### Added

- Add the settings option to show the min/max reference lines

## [1.1.0] - 2025-02-16

### Added

- Add the hour marks to the bottom of the temperature chart

## [1.0.0] - 2025-02-12

### Added

- Add current time to the main view
- Implement the glance view
- Use layouts instead of direct drawing
- Add support for a large number of watches
- Support both Celsius and Fahrenheit

### Changed

- Use triangles to mark minimum and maximum temperatures on the chart
- Increase the buffer zone between the top/bottom lines of the chart and the actual data
- Separate the app state into a separate class
- Separate the chart into a standalone drawable class
- Automatically determine the best temperature data history size based on the screen resolution
- Improve the view styling

### Fixed

- Fix the side and bottom lines of the chart
- Prevent multiple min/max triangle markings
- Update the data every 60 seconds

## [0.0.1] - 2025-01-28

### Added

- Basic functionality
- Support for Instinct 2

[unreleased]: https://github.com/zivke/SimpTemp/compare/v1.3.1...HEAD
[1.3.1]: https://github.com/zivke/SimpTemp/compare/v1.3.0...v1.3.1
[1.3.0]: https://github.com/zivke/SimpTemp/compare/v1.2.1...v1.3.0
[1.2.1]: https://github.com/zivke/SimpTemp/compare/v1.2.0...v1.2.1
[1.2.0]: https://github.com/zivke/SimpTemp/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/zivke/SimpTemp/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/zivke/SimpTemp/compare/v0.0.1...v1.0.0
[0.0.1]: https://github.com/zivke/SimpTemp/releases/tag/v0.0.1