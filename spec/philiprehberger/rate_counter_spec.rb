# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Philiprehberger::RateCounter do
  it 'has a version number' do
    expect(Philiprehberger::RateCounter::VERSION).not_to be_nil
  end

  describe Philiprehberger::RateCounter::Counter do
    describe '#initialize' do
      it 'creates a counter with default window' do
        counter = described_class.new
        expect(counter.count).to eq(0)
      end

      it 'creates a counter with custom window' do
        counter = described_class.new(window: 30)
        expect(counter.count).to eq(0)
      end

      it 'raises on non-positive window' do
        expect { described_class.new(window: 0) }.to raise_error(Philiprehberger::RateCounter::Error)
        expect { described_class.new(window: -1) }.to raise_error(Philiprehberger::RateCounter::Error)
      end
    end

    describe '#increment' do
      it 'increments by 1 by default' do
        counter = described_class.new(window: 60)
        counter.increment
        expect(counter.count).to eq(1)
      end

      it 'increments by a specified amount' do
        counter = described_class.new(window: 60)
        counter.increment(5)
        expect(counter.count).to eq(5)
      end

      it 'accumulates multiple increments' do
        counter = described_class.new(window: 60)
        counter.increment
        counter.increment(3)
        counter.increment(2)
        expect(counter.count).to eq(6)
      end

      it 'returns self for chaining' do
        counter = described_class.new(window: 60)
        expect(counter.increment).to be(counter)
      end
    end

    describe '#count' do
      it 'returns 0 for empty counter' do
        counter = described_class.new(window: 60)
        expect(counter.count).to eq(0)
      end

      it 'returns total events within window' do
        counter = described_class.new(window: 60)
        counter.increment(10)
        counter.increment(20)
        expect(counter.count).to eq(30)
      end
    end

    describe '#rate' do
      it 'returns 0.0 for empty counter' do
        counter = described_class.new(window: 60)
        expect(counter.rate).to eq(0.0)
      end

      it 'returns events per second' do
        counter = described_class.new(window: 60)
        counter.increment(60)
        expect(counter.rate).to be_within(0.1).of(1.0)
      end

      it 'calculates rate based on window size' do
        counter = described_class.new(window: 10)
        counter.increment(100)
        expect(counter.rate).to be_within(0.1).of(10.0)
      end
    end

    describe '#rate_per' do
      it 'returns rate per second' do
        counter = described_class.new(window: 60)
        counter.increment(60)
        expect(counter.rate_per(:second)).to be_within(0.1).of(1.0)
      end

      it 'returns rate per minute' do
        counter = described_class.new(window: 60)
        counter.increment(60)
        expect(counter.rate_per(:minute)).to be_within(1.0).of(60.0)
      end

      it 'returns rate per hour' do
        counter = described_class.new(window: 60)
        counter.increment(60)
        expect(counter.rate_per(:hour)).to be_within(100.0).of(3600.0)
      end

      it 'raises on unknown unit' do
        counter = described_class.new(window: 60)
        expect { counter.rate_per(:day) }.to raise_error(Philiprehberger::RateCounter::Error)
      end
    end

    describe '#reset' do
      it 'clears all events' do
        counter = described_class.new(window: 60)
        counter.increment(100)
        counter.reset
        expect(counter.count).to eq(0)
        expect(counter.rate).to eq(0.0)
      end
    end

    describe 'thread safety' do
      it 'handles concurrent increments' do
        counter = described_class.new(window: 60)
        threads = Array.new(10) do
          Thread.new { 100.times { counter.increment } }
        end
        threads.each(&:join)
        expect(counter.count).to eq(1000)
      end
    end
  end

  describe Philiprehberger::RateCounter::Registry do
    describe '#[]' do
      it 'creates counters on demand' do
        reg = described_class.new(window: 60)
        counter = reg[:requests]
        expect(counter).to be_a(Philiprehberger::RateCounter::Counter)
      end

      it 'returns the same counter for the same name' do
        reg = described_class.new(window: 60)
        expect(reg[:requests]).to be(reg[:requests])
      end

      it 'returns different counters for different names' do
        reg = described_class.new(window: 60)
        expect(reg[:requests]).not_to be(reg[:errors])
      end
    end

    describe '#names' do
      it 'returns empty array for new registry' do
        reg = described_class.new(window: 60)
        expect(reg.names).to eq([])
      end

      it 'returns all registered counter names' do
        reg = described_class.new(window: 60)
        reg[:requests]
        reg[:errors]
        expect(reg.names).to contain_exactly(:requests, :errors)
      end
    end

    describe '#size' do
      it 'returns 0 for new registry' do
        reg = described_class.new(window: 60)
        expect(reg.size).to eq(0)
      end

      it 'returns the number of counters' do
        reg = described_class.new(window: 60)
        reg[:a]
        reg[:b]
        expect(reg.size).to eq(2)
      end
    end

    describe '#reset_all' do
      it 'resets all counters' do
        reg = described_class.new(window: 60)
        reg[:requests].increment(100)
        reg[:errors].increment(50)
        reg.reset_all
        expect(reg[:requests].count).to eq(0)
        expect(reg[:errors].count).to eq(0)
      end
    end

    describe 'independent counters' do
      it 'tracks counters independently' do
        reg = described_class.new(window: 60)
        reg[:requests].increment(10)
        reg[:errors].increment(2)
        expect(reg[:requests].count).to eq(10)
        expect(reg[:errors].count).to eq(2)
      end
    end

    describe 'auto-creation' do
      it 'creates a new counter on first access' do
        reg = described_class.new(window: 60)
        expect(reg.size).to eq(0)
        reg[:new_counter]
        expect(reg.size).to eq(1)
      end

      it 'accepts string keys' do
        reg = described_class.new(window: 60)
        reg['requests'].increment
        expect(reg['requests'].count).to eq(1)
      end
    end
  end

  describe Philiprehberger::RateCounter::Counter do
    describe 'high-frequency increments' do
      it 'handles many rapid increments' do
        counter = described_class.new(window: 60)
        500.times { counter.increment }
        expect(counter.count).to eq(500)
      end
    end

    describe '#rate_per with different units' do
      it 'rate_per second equals base rate' do
        counter = described_class.new(window: 10)
        counter.increment(50)
        expect(counter.rate_per(:second)).to be_within(0.1).of(5.0)
      end

      it 'rate_per minute is 60x base rate' do
        counter = described_class.new(window: 10)
        counter.increment(50)
        expect(counter.rate_per(:minute)).to be_within(1.0).of(300.0)
      end

      it 'rate_per hour is 3600x base rate' do
        counter = described_class.new(window: 10)
        counter.increment(50)
        expect(counter.rate_per(:hour)).to be_within(100.0).of(18_000.0)
      end
    end

    describe '#reset behavior' do
      it 'rate returns 0.0 after reset' do
        counter = described_class.new(window: 60)
        counter.increment(100)
        counter.reset
        expect(counter.rate).to eq(0.0)
      end

      it 'count returns 0 after reset' do
        counter = described_class.new(window: 60)
        counter.increment(50)
        counter.reset
        expect(counter.count).to eq(0)
      end

      it 'can increment after reset' do
        counter = described_class.new(window: 60)
        counter.increment(100)
        counter.reset
        counter.increment(5)
        expect(counter.count).to eq(5)
      end
    end

    describe 'very short window' do
      it 'accepts a fractional-second window' do
        counter = described_class.new(window: 0.001)
        counter.increment(10)
        expect(counter.count).to be >= 0
      end

      it 'raises for zero window' do
        expect { described_class.new(window: 0) }.to raise_error(Philiprehberger::RateCounter::Error)
      end

      it 'raises for negative window' do
        expect { described_class.new(window: -5) }.to raise_error(Philiprehberger::RateCounter::Error)
      end
    end

    describe 'increment chaining' do
      it 'chains multiple increments' do
        counter = described_class.new(window: 60)
        counter.increment(1).increment(2).increment(3)
        expect(counter.count).to eq(6)
      end
    end
  end

  describe 'peak_rate' do
    it 'starts at zero' do
      counter = Philiprehberger::RateCounter::Counter.new(window: 60)
      expect(counter.peak_rate).to eq(0.0)
    end

    it 'tracks the highest rate observed' do
      counter = Philiprehberger::RateCounter::Counter.new(window: 60)
      10.times { counter.increment }
      peak = counter.peak_rate
      expect(peak).to be > 0.0
    end

    it 'resets with counter' do
      counter = Philiprehberger::RateCounter::Counter.new(window: 60)
      5.times { counter.increment }
      counter.reset
      expect(counter.peak_rate).to eq(0.0)
    end
  end

  describe 'snapshot' do
    it 'returns a frozen hash with expected keys' do
      counter = Philiprehberger::RateCounter::Counter.new(window: 60)
      counter.increment(5)
      snap = counter.snapshot
      expect(snap).to be_frozen
      expect(snap.keys).to contain_exactly(:count, :rate, :peak_rate, :window, :timestamp)
    end

    it 'has correct count' do
      counter = Philiprehberger::RateCounter::Counter.new(window: 60)
      counter.increment(3)
      expect(counter.snapshot[:count]).to eq(3)
    end

    it 'has correct window' do
      counter = Philiprehberger::RateCounter::Counter.new(window: 30)
      expect(counter.snapshot[:window]).to eq(30)
    end

    it 'has a timestamp' do
      counter = Philiprehberger::RateCounter::Counter.new(window: 60)
      expect(counter.snapshot[:timestamp]).to be_a(Float)
    end

    it 'includes peak_rate' do
      counter = Philiprehberger::RateCounter::Counter.new(window: 60)
      counter.increment(10)
      expect(counter.snapshot[:peak_rate]).to be >= 0.0
    end
  end

  describe 'registry snapshot' do
    it 'returns snapshots for all counters' do
      registry = Philiprehberger::RateCounter::Registry.new
      registry[:api].increment(5)
      registry[:db].increment(3)
      snap = registry.snapshot
      expect(snap.keys).to contain_exactly(:api, :db)
      expect(snap[:api][:count]).to eq(5)
      expect(snap[:db][:count]).to eq(3)
    end

    it 'returns frozen hash' do
      registry = Philiprehberger::RateCounter::Registry.new
      registry[:test].increment
      expect(registry.snapshot).to be_frozen
    end

    it 'returns empty hash for empty registry' do
      registry = Philiprehberger::RateCounter::Registry.new
      expect(registry.snapshot).to eq({})
    end
  end
end
