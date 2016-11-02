# philiprehberger-rate_counter

[![Tests](https://github.com/philiprehberger/rb-rate-counter/actions/workflows/ci.yml/badge.svg)](https://github.com/philiprehberger/rb-rate-counter/actions/workflows/ci.yml)
[![Gem Version](https://badge.fury.io/rb/philiprehberger-rate_counter.svg)](https://rubygems.org/gems/philiprehberger-rate_counter)
[![License](https://img.shields.io/github/license/philiprehberger/rb-rate-counter)](LICENSE)

Sliding-window rate counter for measuring event throughput in real-time

## Requirements

- Ruby >= 3.1

## Installation

Add to your Gemfile:

```ruby
gem "philiprehberger-rate_counter"
```

Or install directly:

```bash
gem install philiprehberger-rate_counter
```

## Usage

```ruby
require 'philiprehberger/rate_counter'

counter = Philiprehberger::RateCounter::Counter.new(window: 60)
counter.increment
counter.increment(5)
counter.rate              # => events per second
counter.count             # => total events in window
counter.rate_per(:minute) # => events per minute
```

### Registry

Manage multiple named counters with a shared window configuration:

```ruby
reg = Philiprehberger::RateCounter::Registry.new(window: 60)
reg[:requests].increment
reg[:errors].increment
reg[:requests].rate        # => request rate
reg[:errors].count         # => error count in window
reg.names                  # => [:requests, :errors]
reg.reset_all              # => reset all counters
```

## API

### `Philiprehberger::RateCounter::Counter`

| Method | Description |
|--------|-------------|
| `.new(window:)` | Create a counter with a sliding window (seconds) |
| `#increment(n)` | Record `n` events (default: 1) |
| `#rate` | Events per second over the window |
| `#count` | Total events within the window |
| `#rate_per(unit)` | Projected rate per `:second`, `:minute`, or `:hour` |
| `#reset` | Clear all recorded events |

### `Philiprehberger::RateCounter::Registry`

| Method | Description |
|--------|-------------|
| `.new(window:)` | Create a registry with a default window for new counters |
| `#[](name)` | Access or create a named counter |
| `#names` | List all registered counter names |
| `#size` | Number of registered counters |
| `#reset_all` | Reset all counters |

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## License

MIT
