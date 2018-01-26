require File.expand_path(File.join(File.dirname(__FILE__), 'files.rb'))

### Specification for the new Gem
Gem::Specification.new do |spec|
  spec.name          = 'asynchronous'
  spec.version       = File.open(File.join(File.dirname(__FILE__), 'VERSION')).read.split("\n")[0].chomp.delete(' ')
  spec.authors       = ['Adam Luzsi']
  spec.email         = ['adamluzsi@gmail.com']
  spec.description   = 'Thread like interface for Kernel fork for parallel programming in MRI ruby. Anti zombi process following included'
  spec.summary       = 'Thread like interface for Kernel fork for parallel programming in MRI ruby'
  spec.homepage      = 'https://github.com/adamluzsi/asynchronous'
  spec.license       = "MIT"

  spec.files         = SpecFiles
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']
end
