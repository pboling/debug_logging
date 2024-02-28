# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Added
### Changed
### Fixed
### Removed

## [4.0.0] - unreleased
### Added
- Class method DSL:
    - `logged`
- Instance method DSL:
    - `i_logged`
### Changed
- Class method DSL renamed:
  - `notifies` => `notified`
- Instance method DSL renamed:
  - `i_notifies` => `i_notified`
- Disambiguated class method log output send message separator:
  - `.` => `::`, because `.` is ambiguous; same call syntax used for instance method calls
### Fixed
- Per method config for every decorated method
### Removed
- Support for `include DebugLogging::InstanceLogger.new(...)`
- Support for `include DebugLogging::InstanceNotifier.new(...)`

## [3.1.9] - 2023-10-31
### Fixed
- Maximum Ruby version is 2.7. Versions 3.x are not compatible with Ruby >= 3

## [3.1.8] - 2020-12-19

## [3.1.7] - 2020-12-19

## [3.1.6] - tagged, but unreleased

## [3.1.5] - 2020-12-18

## [3.1.4] - 2020-12-18

## [3.1.3] - 2020-12-18

## [3.1.2] - 2020-12-10

## [3.1.1] - 2020-12-09

## [3.1.0] - 2020-10-24

## [3.0.0] - 2020-10-07

## [2.0.0] - 2020-10-06

## [1.0.17] - 2018-09-10

## [1.0.16] - 2018-01-16

## [1.0.15] - 2017-10-17

## [1.0.14] - 2017-10-09

## [1.0.13] - 2017-10-08

## [1.0.12] - 2017-10-08

## [1.0.11] - 2017-10-06

## [1.0.10] - 2017-09-26

## [1.0.9] - 2017-09-06

## [1.0.8] - 2017-09-06

## [1.0.7] - 2017-09-06

## [1.0.6] - 2017-09-05

## [1.0.5] ([tag][1.0.1t]) - 2017-03-31

## [1.0.4] ([tag][1.0.4t]) - 2017-03-31

## [1.0.3] ([tag][1.0.3t]) - 2017-03-31

## [1.0.2] ([tag][1.0.2t]) - 2017-03-30

## [1.0.1] ([tag][1.0.1t]) - 2017-03-29

## [1.0.0] ([tag][1.0.0t]) - 2017-03-26

## [0.1.0] ([tag][0.1.0t]) - 2017-03-25
- Initial release

[Unreleased]: https://gitlab.com/kettle-rb/kettle-soup-cover/-/compare/v3.1.9...HEAD
[3.1.9t]: https://gitlab.com/pboling/debug_logging/-/tags/v3.1.9
[3.1.9]: https://gitlab.com/kettle-rb/kettle-soup-cover/-/compare/v3.1.8...v3.1.9
[3.1.8t]: https://gitlab.com/pboling/debug_logging/-/tags/v3.1.8
[3.1.8]: https://gitlab.com/kettle-rb/kettle-soup-cover/-/compare/v3.1.7...v3.1.8
[3.1.7t]: https://gitlab.com/pboling/debug_logging/-/tags/v3.1.7
[3.1.7]: https://gitlab.com/kettle-rb/kettle-soup-cover/-/compare/v3.1.6...v3.1.7
[3.1.6t]: https://gitlab.com/pboling/debug_logging/-/tags/v3.1.6
[3.1.6]: https://gitlab.com/kettle-rb/kettle-soup-cover/-/compare/v3.1.5...v3.1.6
[3.1.5t]: https://gitlab.com/pboling/debug_logging/-/tags/v3.1.5
[3.1.5]: https://gitlab.com/kettle-rb/kettle-soup-cover/-/compare/v3.1.4...v3.1.5
[3.1.4t]: https://gitlab.com/pboling/debug_logging/-/tags/v3.1.4
[3.1.4]: https://gitlab.com/kettle-rb/kettle-soup-cover/-/compare/v3.1.3...v3.1.4
[3.1.3t]: https://gitlab.com/pboling/debug_logging/-/tags/v3.1.3
[3.1.3]: https://gitlab.com/kettle-rb/kettle-soup-cover/-/compare/v3.1.2...v3.1.3
[3.1.2t]: https://gitlab.com/pboling/debug_logging/-/tags/v3.1.2
[3.1.2]: https://gitlab.com/kettle-rb/kettle-soup-cover/-/compare/v3.1.1...v3.1.2
[3.1.1t]: https://gitlab.com/pboling/debug_logging/-/tags/v3.1.1
[3.1.1]: https://gitlab.com/kettle-rb/kettle-soup-cover/-/compare/v3.1.0...v3.1.1
[3.1.0t]: https://gitlab.com/pboling/debug_logging/-/tags/v3.1.0
[3.1.0]: https://gitlab.com/kettle-rb/kettle-soup-cover/-/compare/v3.0.0...v3.1.0
[3.0.0t]: https://gitlab.com/pboling/debug_logging/-/tags/v3.0.0
[3.0.0]: https://gitlab.com/kettle-rb/kettle-soup-cover/-/compare/v2.0.0...v3.0.0
[2.0.0t]: https://gitlab.com/pboling/debug_logging/-/tags/v2.0.0
[2.0.0]: https://gitlab.com/kettle-rb/kettle-soup-cover/-/compare/v1.0.17...v2.0.0
[1.0.17t]: https://gitlab.com/pboling/debug_logging/-/tags/v1.0.17
[1.0.17]: https://gitlab.com/kettle-rb/kettle-soup-cover/-/compare/v1.0.16...v1.0.17
[1.0.16t]: https://gitlab.com/pboling/debug_logging/-/tags/v1.0.16
[1.0.16]: https://gitlab.com/kettle-rb/kettle-soup-cover/-/compare/v1.0.15...v1.0.16
[1.0.15t]: https://gitlab.com/pboling/debug_logging/-/tags/v1.0.15
[1.0.15]: https://gitlab.com/kettle-rb/kettle-soup-cover/-/compare/v1.0.14...v1.0.15
[1.0.14t]: https://gitlab.com/pboling/debug_logging/-/tags/v1.0.14
[1.0.14]: https://gitlab.com/kettle-rb/kettle-soup-cover/-/compare/v1.0.13...v1.0.14
[1.0.13t]: https://gitlab.com/pboling/debug_logging/-/tags/v1.0.13
[1.0.13]: https://gitlab.com/kettle-rb/kettle-soup-cover/-/compare/v1.0.12...v1.0.13
[1.0.12t]: https://gitlab.com/pboling/debug_logging/-/tags/v1.0.12
[1.0.12]: https://gitlab.com/kettle-rb/kettle-soup-cover/-/compare/v1.0.11...v1.0.12
[1.0.11t]: https://gitlab.com/pboling/debug_logging/-/tags/v1.0.11
[1.0.11]: https://gitlab.com/kettle-rb/kettle-soup-cover/-/compare/v1.0.10...v1.0.11
[1.0.10t]: https://gitlab.com/pboling/debug_logging/-/tags/v1.0.10
[1.0.10]: https://gitlab.com/kettle-rb/kettle-soup-cover/-/compare/v1.0.9...v1.0.10
[1.0.9t]: https://gitlab.com/pboling/debug_logging/-/tags/v1.0.9
[1.0.9]: https://gitlab.com/kettle-rb/kettle-soup-cover/-/compare/v1.0.8...v1.0.9
[1.0.8t]: https://gitlab.com/pboling/debug_logging/-/tags/v1.0.8
[1.0.8]: https://gitlab.com/kettle-rb/kettle-soup-cover/-/compare/v1.0.7...v1.0.8
[1.0.7t]: https://gitlab.com/pboling/debug_logging/-/tags/v1.0.7
[1.0.7]: https://gitlab.com/kettle-rb/kettle-soup-cover/-/compare/v1.0.6...v1.0.7
[1.0.6t]: https://gitlab.com/pboling/debug_logging/-/tags/v1.0.6
[1.0.6]: https://gitlab.com/kettle-rb/kettle-soup-cover/-/compare/v1.0.5...v1.0.6
[1.0.5t]: https://gitlab.com/pboling/debug_logging/-/tags/v1.0.5
[1.0.5]: https://gitlab.com/kettle-rb/kettle-soup-cover/-/compare/v1.0.4...v1.0.5
[1.0.4t]: https://gitlab.com/pboling/debug_logging/-/tags/v1.0.4
[1.0.4]: https://gitlab.com/kettle-rb/kettle-soup-cover/-/compare/v1.0.3...v1.0.4
[1.0.3t]: https://gitlab.com/pboling/debug_logging/-/tags/v1.0.3
[1.0.3]: https://gitlab.com/kettle-rb/kettle-soup-cover/-/compare/v1.0.2...v1.0.3
[1.0.2t]: https://gitlab.com/pboling/debug_logging/-/tags/v1.0.2
[1.0.2]: https://gitlab.com/kettle-rb/kettle-soup-cover/-/compare/v1.0.1...v1.0.2
[1.0.1t]: https://gitlab.com/pboling/debug_logging/-/tags/v1.0.1
[1.0.1]: https://gitlab.com/kettle-rb/kettle-soup-cover/-/compare/v1.0.0...v1.0.1
[1.0.0t]: https://gitlab.com/pboling/debug_logging/-/tags/v1.0.0
[1.0.0]: https://gitlab.com/kettle-rb/kettle-soup-cover/-/compare/v0.1.0...v1.0.0
[0.1.0t]: https://gitlab.com/pboling/debug_logging/-/tags/v0.1.0
[0.1.0]: https://gitlab.com/pboling/debug_logging/-/compare/f648ea6832aa85232d320b4c4acc4a84e44a83d3...v0.1.0
