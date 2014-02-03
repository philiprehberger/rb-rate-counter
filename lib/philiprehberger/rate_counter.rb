# frozen_string_literal: true

require_relative 'rate_counter/version'
require_relative 'rate_counter/registry'

module Philiprehberger
  module RateCounter
    class Error < StandardError; end

    RATE_UNITS = {
      second: 1,
      minute: 60,
      hour: 3600
    }.freeze

    # A sliding-window rate counter for measuring event throughput
    #
    # @example
    #   counter = Counter.new(window: 60)
    #   counter.increment
    #   counter.rate  # => events per second
    class Counter
      # Create a new rate counter
      #
      # @param window [Numeric] the sliding window size in seconds
      # @raise [Error] if window is not positive
      def initialize(window: 60)
        raise Error, 'Window must be positive' unless window.is_a?(Numeric) && window.positive?

        @window = window
        @buckets = []
        @mutex = Mutex.new
      end

      # Increment the counter
      #
      # @param n [Integer] number of events to record (default: 1)
      # @return [self]
      def increment(n = 1)
        @mutex.synchronize do
          @buckets << [now, n]
        end
        self
      end

      # Get the current event count within the window
      #
      # @return [Integer] total events in the current window
      def count
        @mutex.synchronize do
          prune
          @buckets.sum { |_ts, n| n }
        end
      end

      # Get the rate of events per second
      #
      # @return [Float] events per second
      def rate
        @mutex.synchronize do
          prune
          return 0.0 if @buckets.empty?

          total = @buckets.sum { |_ts, n| n }
          total.to_f / @window
        end
      end

      # Get the rate projected to a specific time unit
      #
      # @param unit [Symbol] :second, :minute, or :hour
      # @return [Float] events per unit
      # @raise [Error] if unit is unknown
      def rate_per(unit)
        multiplier = RATE_UNITS[unit]
        raise Error, "Unknown unit: #{unit}. Use :second, :minute, or :hour" unless multiplier

        rate * multiplier
      end

      # Reset the counter
      #
      # @return [void]
      def reset
        @mutex.synchronize { @buckets.clear }
      end

      private

      def now
        Process.clock_gettime(Process::CLOCK_MONOTONIC)
      end

      def prune
        cutoff = now - @window
        @buckets.reject! { |ts, _n| ts < cutoff }
      end
    end
  end
end
