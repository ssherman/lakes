# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'version'
Gem::Specification.new do |spec|
  spec.name          = "lakes"
  spec.version       = Lakes::VERSION
  spec.authors       = ["Shane Sherman"]
  spec.email         = ["shane.sherman@gmail.com"]

  spec.summary       = 'This gem parses lake details from various government websites'
  spec.description   = 'I wrote this gem to originally parse texas lake data'
  spec.homepage      = 'https://github.com/ssherman/lakes'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 12.3"
  spec.add_development_dependency "minitest", "~> 5.11"
  spec.add_development_dependency "mocha", "~> 1.2"
  spec.add_dependency 'nokogiri', "~> 1.10"
end
