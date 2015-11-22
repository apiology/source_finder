# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'source_finder/version'

Gem::Specification.new do |spec|
  spec.name          = 'source_finder'
  spec.version       = SourceFinder::VERSION
  spec.authors       = ['Vince Broz']
  spec.email         = ['vince@broz.cc']

  spec.summary       = 'SourceFinder finds source and documentation files ' \
                       'within a project.'
  spec.homepage      = 'https://github.com/apiology/source_finder'
  spec.license       = 'MIT'

  spec.files         = Dir["CODE_OF_CONDUCT.md", "LICENSE.txt", "README.md",
                           "{lib}/source_finder.rb",
                           "{lib}/source_finder/**/*.rb",
                           "source_finder.gemspec"]
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.10'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'quality'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'simplecov'
end
