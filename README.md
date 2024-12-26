# philiprehberger-rate_counter

[![Tests](https://github.com/philiprehberger/rb-rate-counter/actions/workflows/ci.yml/badge.svg)](https://github.com/philiprehberger/rb-rate-counter/actions/workflows/ci.yml)
[![Gem Version](https://badge.fury.io/rb/philiprehberger-rate_counter.svg)](https://rubygems.org/gems/philiprehberger-rate_counter)
[![Last updated](https://img.shields.io/github/last-commit/philiprehberger/rb-rate-counter)](https://github.com/philiprehberger/rb-rate-counter/commits/main)

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
require "philiprehberger/rate_counter"

counter = Philiprehberger::RateCounter::Counter.new(window: 60)
counter.increment
counter.increment(5)
counter.rate              # => events per second
counter.count             # => total events in window
counter.rate_per(:minute) # => events per minute
```

### Peak Rate and Snapshots

```ruby
require "philiprehberger/rate_counter"

counter = Philiprehberger::RateCounter::Counter.new(window: 60)
100.times { counter.increment }

counter.peak_rate           # => highest rate per second observed
counter.snapshot            # => { count: 100, rate: 16.7, peak_rate: 16.7, window: 60, timestamp: ... }

registry = Philiprehberger::RateCounter::Registry.new
registry[:api].increment(50)
registry.snapshot           # => { api: { count: 50, rate: ..., ... } }
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
| `#peak_rate` | Highest rate per second observed since creation or last reset |
| `#snapshot` | Frozen hash with count, rate, peak_rate, window, and timestamp |
| `#reset` | Clear all recorded events |

### `Philiprehberger::RateCounter::Registry`

| Method | Description |
|--------|-------------|
| `.new(window:)` | Create a registry with a default window for new counters |
| `#[](name)` | Access or create a named counter |
| `#names` | List all registered counter names |
| `#size` | Number of registered counters |
| `#snapshot` | Frozen hash of name to counter snapshot |
| `#reset_all` | Reset all counters |

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## Support

If you find this project useful:

⭐ [Star the repo](https://github.com/philiprehberger/rb-rate-counter)

🐛 [Report issues](https://github.com/philiprehberger/rb-rate-counter/issues?q=is%3Aissue+is%3Aopen+label%3Abug)

💡 [Suggest features](https://github.com/philiprehberger/rb-rate-counter/issues?q=is%3Aissue+is%3Aopen+label%3Aenhancement)

❤️ [Sponsor development](https://github.com/sponsors/philiprehberger)

🌐 [All Open Source Projects](https://philiprehberger.com/open-source-packages)

💻 [GitHub Profile](https://github.com/philiprehberger)

🔗 [LinkedIn Profile](https://www.linkedin.com/in/philiprehberger)

## License

[MIT](LICENSE)
