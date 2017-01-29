# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'restmachine/version'

Gem::Specification.new do |spec|
  spec.name          = "restmachine"
  spec.version       = Restmachine::VERSION
  spec.authors       = ["Ryan Festag"]
  spec.email         = ["rfestag@gmail.com"]

  spec.summary       = %q{A framework for implement RESTful web services with Web Machine}
  spec.homepage      = "http://git.com"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency 'mongoid', '~> 5.1'
  spec.add_development_dependency 'webmachine-test', '~> 0.3'
  spec.add_development_dependency 'simplecov', '~> 0.11'
  spec.add_development_dependency 'reel', "~> 0.6"
  spec.add_development_dependency 'pry'
  spec.add_dependency "webmachine", "~> 1.4"
  spec.add_dependency "webmachine-actionview", "~> 0.0"
  spec.add_dependency "jwt", "~> 1.5"
  spec.add_dependency "activesupport", "~> 4.2"
  spec.add_dependency "pundit", "~> 1.1"
  spec.add_dependency "mimemagic"
  spec.add_dependency "thor"
  spec.add_dependency "treetop"
  spec.add_dependency "seconds"
end
