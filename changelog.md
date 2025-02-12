# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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

[unreleased]: https://github.com/zivke/SimpTemp/compare/v1.1.1...HEAD
[1.0.0]: https://github.com/zivke/SimpTemp/compare/v0.3.0...v1.0.0
[0.0.1]: https://github.com/zivke/SimpTemp/releases/tag/v0.0.1