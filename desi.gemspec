# -*- encoding: utf-8 -*-
require File.expand_path('../lib/desi/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "desi"
  gem.authors       = ["Dominique Rose-Rosette"]
  gem.email         = ["drose-rosette@af83.com"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""
  gem.version       = Desi::VERSION

  gem.add_dependency "boson"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
