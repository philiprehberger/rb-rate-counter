# Changelog

All notable changes to this gem will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this gem adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.3.0] - 2026-04-17

### Added
- `Counter#time_since_last` returns seconds since the most recent increment, or `nil` if the window is empty

## [0.2.0] - 2026-04-04

### Added
- `Counter#peak_rate` for tracking highest observed rate
- `Counter#snapshot` for exporting counter state as a frozen hash
- `Registry#snapshot` for exporting all counter states
- GitHub issue template gem version field
- Feature request "Alternatives considered" field

## [0.1.6] - 2026-03-31

### Added
- Add GitHub issue templates, dependabot config, and PR template

## [0.1.5] - 2026-03-31

### Changed
- Standardize README badges, support section, and license format

## [0.1.4] - 2026-03-24

### Fixed
- Standardize README code examples to use double-quote require statements

## [0.1.3] - 2026-03-24

### Fixed
- Fix Installation section quote style to double quotes
- Remove inline comments from Development section to match template

## [0.1.2] - 2026-03-22

### Changed
- Expand test coverage to 41 examples

## [0.1.1] - 2026-03-22

### Changed
- Improve source code, tests, and rubocop compliance

## [0.1.0] - 2026-03-21

### Added
- Initial release
- Sliding-window `Counter` with configurable window size
- `increment(n)` to record events
- `rate` for events per second and `count` for total events in window
- `rate_per(:second | :minute | :hour)` for projected rates
- `Registry` class for managing named counters with shared configuration
- Thread-safe implementation with Mutex
- Lazy expiration of old events on read
