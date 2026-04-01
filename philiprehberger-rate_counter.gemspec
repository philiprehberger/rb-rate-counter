# frozen_string_literal: true

require_relative 'lib/philiprehberger/rate_counter/version'

Gem::Specification.new do |spec|
  spec.name = 'philiprehberger-rate_counter'
  spec.version = Philiprehberger::RateCounter::VERSION
  spec.authors = ['Philip Rehberger']
  spec.email = ['me@philiprehberger.com']

  spec.summary = 'Sliding-window rate counter for measuring event throughput in real-time'
  spec.description = 'Measure event rates (requests/sec, errors/min) using a sliding window counter. ' \
                       'Thread-safe, no background threads, supports named counter registries.'
  spec.homepage = 'https://philiprehberger.com/open-source-packages/ruby/philiprehberger-rate_counter'
  spec.license = 'MIT'

  spec.required_ruby_version = '>= 3.1.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/philiprehberger/rb-rate-counter'
  spec.metadata['changelog_uri'] = 'https://github.com/philiprehberger/rb-rate-counter/blob/main/CHANGELOG.md'
  spec.metadata['bug_tracker_uri'] = 'https://github.com/philiprehberger/rb-rate-counter/issues'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir['lib/**/*.rb', 'LICENSE', 'README.md', 'CHANGELOG.md']
  spec.require_paths = ['lib']
end
