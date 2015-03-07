# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'icu_utils/version'

Gem::Specification.new do |s|
  s.name             = "icu_utils"
  s.version          = ICU::Utils::VERSION
  s.authors          = ["Mark Orr"]
  s.email            = ["mark.j.l.orr@googlemail.com"]
  s.description      = %q{A place for shared utilities for sharing between the various ICU apps and gems}
  s.summary          = %q{Shared ICU utilities}
  s.homepage         = "http://github.com/sanichi/icu_utils"
  s.license          = "MIT"

  s.extra_rdoc_files = %w(LICENSE.txt README.md)
  s.files            = `git ls-files`.split($/)
  s.test_files       = s.files.grep(%r{^(spec)/})
  s.require_paths    = ["lib"]

  s.add_development_dependency "bundler", "~> 1.8"
  s.add_development_dependency "rake", "~> 10.4"
  s.add_development_dependency "rspec", "~> 3.2"
  s.add_development_dependency "rdoc", "~> 4.2"
end
