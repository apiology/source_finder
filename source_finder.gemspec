# coding: ascii
# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'source_finder/version'

Gem::Specification.new do |spec|
  spec.name          = 'source_finder'
  spec.version       = SourceFinder::VERSION
  spec.authors       = ["Vince Broz"]
  spec.email         = ['vince@broz.cc']
  spec.summary       = "SourceFinder's job is to find source files in your project in a configurable way--useful for things like static analysis quality tools."
  spec.homepage      = 'https://github.com/apiology/source_finder'
  spec.license       = 'MIT license'
  spec.required_ruby_version = '>= 2.7'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      f.match(%r{^(test|spec|features)/})
    end
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # spec.add_runtime_dependency 'activesupport'

  spec.add_development_dependency 'bump'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'fakeweb'
  spec.add_development_dependency 'mdl'
  # 0.58.0 and 0.57.0 don't seem super compatible with signatures, and
  # magit doesn't seem to want to use the bundled version at the moment,
  # so let's favor the more recent version...
  spec.add_development_dependency 'overcommit', ['>=0.58.0']
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '>=3.4'
  spec.add_development_dependency 'rubocop', ['~> 1.36']
  spec.add_development_dependency 'rubocop-rake'
  # ensure version with RSpec/VerifiedDoubleReference
  spec.add_development_dependency 'rubocop-rspec', ['>=2.10.0']
  # ensure version with branch coverage
  spec.add_development_dependency 'simplecov', ['>=0.18.0']
  spec.add_development_dependency 'simplecov-lcov'
  spec.add_development_dependency 'undercover'
  spec.add_development_dependency 'webmock'
  spec.metadata = {
    'rubygems_mfa_required' => 'true',
  }
end
