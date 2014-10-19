# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'indian/version'

Gem::Specification.new do |spec|
  spec.name          = "indian"
  spec.version       = Indian::VERSION
  spec.authors       = ["Richard Bishop"]
  spec.email         = ["richard@rubiquity.com"]
  spec.summary       = %q{An experimental web server using modern Linux kernel features.}
  spec.description   = %q{An experimental web server using modern Linux kernel features.}
  spec.homepage      = "https://github.com/rbishop/indian"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "http_parser.rb", "~> 0.6"
  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end
