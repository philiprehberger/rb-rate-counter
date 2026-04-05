# frozen_string_literal: true

module Philiprehberger
  module RateCounter
    # A registry of named rate counters with a shared default window
    #
    # @example
    #   reg = Registry.new(window: 60)
    #   reg[:requests].increment
    #   reg[:errors].increment
    #   reg[:requests].rate
    class Registry
      # Create a new registry
      #
      # @param window [Numeric] default window size in seconds for new counters
      def initialize(window: 60)
        @window = window
        @counters = {}
        @mutex = Mutex.new
      end

      # Access or create a named counter
      #
      # @param name [Symbol, String] the counter name
      # @return [Counter] the named counter
      def [](name)
        @mutex.synchronize do
          @counters[name] ||= Counter.new(window: @window)
        end
      end

      # List all registered counter names
      #
      # @return [Array<Symbol, String>]
      def names
        @mutex.synchronize { @counters.keys }
      end

      # Reset all counters
      #
      # @return [void]
      def reset_all
        @mutex.synchronize do
          @counters.each_value(&:reset)
        end
      end

      # Return the number of registered counters
      #
      # @return [Integer]
      def size
        @mutex.synchronize { @counters.size }
      end

      # Return a frozen snapshot of all counter states
      #
      # @return [Hash] frozen hash of name to counter snapshot
      def snapshot
        @mutex.synchronize do
          @counters.each_with_object({}) do |(name, counter), result|
            result[name] = counter.snapshot
          end.freeze
        end
      end
    end
  end
end
