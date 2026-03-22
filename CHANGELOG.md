# Changelog

All notable changes to this gem will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this gem adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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
