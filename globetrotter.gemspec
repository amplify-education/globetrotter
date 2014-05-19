# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'globetrotter/version'

Gem::Specification.new do |spec|
  spec.name          = 'globetrotter'
  spec.version       = Globetrotter::VERSION
  spec.authors       = ['Nick Lopez']
  spec.email         = ['nlopez@amplify.com']
  spec.summary       = %q{Resolve DNS records at many different nameservers all over the world.}
  # spec.description   = %q{TODO: Write a longer description. Optional.}
  spec.homepage      = 'https://github.com/amplify-education/globetrotter'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'rake'

  spec.add_runtime_dependency 'wrest', '~> 1.5'
  spec.add_runtime_dependency 'dnsruby', '~> 1.54'
  spec.add_runtime_dependency 'eventmachine', '~> 1.0'
end
