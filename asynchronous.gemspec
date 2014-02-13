# coding: utf-8

require File.expand_path(File.join(File.dirname(__FILE__),"files.rb"))

### Specification for the new Gem
Gem::Specification.new do |spec|

  spec.name          = "asynchronous"
  spec.version       = File.open(File.join(File.dirname(__FILE__),"VERSION")).read.split("\n")[0].chomp.gsub(' ','')
  spec.authors       = ["Adam Luzsi"]
  spec.email         = ["adamluzsi@gmail.com"]
  spec.description   = %q{DSL for for dead simple to use asynchronous patterns in both VM managed and OS managed way (Concurrency and Parallelism) }
  spec.summary       = %q{Simple Async Based on standard CRuby}
  spec.homepage      = "https://github.com/adamluzsi/asynchronous"
  #spec.license       = "MIT"

  spec.files         = SpecFiles
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "process_shared"
  spec.add_development_dependency(%q<debugger>, [">= 0"])


end
