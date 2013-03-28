# -*- encoding: utf-8 -*-
require File.expand_path('../lib/typhoid/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Doug Rohde"]
  gem.email         = ["doug.rohde@tstmedia.com"]
  gem.description   = %q{A lightweight ORM-like wrapper around Typhoeus}
  gem.summary       = %q{A lightweight ORM-like wrapper around Typhoeus}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "typhoid"
  gem.require_paths = ["lib"]
  gem.version       = Typhoid::VERSION

  gem.add_dependency 'typhoeus', "0.4.2"

  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'json_pure', [">= 1.4.1"]
end
