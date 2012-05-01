# -*- encoding: utf-8 -*-
require File.expand_path('../lib/ngin_http/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Doug Rohde"]
  gem.email         = ["doug.rohde@tstmedia.com"]
  gem.description   = %q{Wrapper around Typhoeus http gem to provide some extra ORM-like features}
  gem.summary       = %q{Wrapper around Typhoeus http gem to provide some extra ORM-like features}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "ngin_http"
  gem.require_paths = ["lib"]
  gem.version       = NginHttp::VERSION

  gem.add_dependency 'typhoeus'

  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'json_pure', [">= 1.4.1"]
end
