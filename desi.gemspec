# -*- encoding: utf-8 -*-
require File.expand_path('../lib/desi/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "desi"
  gem.authors       = ["Dominique Rose-Rosette"]
  gem.email         = ["drose-rosette@af83.com"]
  gem.summary       = %q{A developer tool to quickly set up an Elastic Search local install.}
  gem.description   = %q{Desi (Developper ElasticSearch Installer) is very simple tool to quickly set up
an Elastic Search local install for development purposes.}
  gem.homepage      = "https://github.com/AF83/desi/"
  gem.licenses      = ['MIT']
  gem.version       = Desi::VERSION

  gem.required_ruby_version = ">= 1.9.3"

  gem.add_dependency "boson"
  gem.add_dependency "cocaine", "~> 0.5.3"
  gem.add_dependency "addressable"

  gem.add_development_dependency "rake"
  gem.add_development_dependency "rspec"
  gem.add_development_dependency "guard-rspec"
  gem.add_development_dependency "guard-yard"
  gem.add_development_dependency "redcarpet"
  gem.add_development_dependency "rb-inotify"
  gem.add_development_dependency "pry"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
