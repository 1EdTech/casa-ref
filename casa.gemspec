# coding: utf-8

Gem::Specification.new do |s|

  s.name        = 'casa'
  s.version     = '0.1.5.dev'
  s.summary     = 'Reference implementation of the Community App Sharing Architecture'
  s.description     = 'Reference implementation of the Community App Sharing Architecture'
  s.authors     = ['Eric Bollens']
  s.email       = ['ebollens@ucla.edu']
  s.homepage    = 'http://imsglobal.github.io/casa'
  s.license     = 'Apache-2.0'

  s.files         = `git ls-files`.split($/)
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ['lib']

  s.add_dependency 'casa-engine'
  s.add_dependency 'casa-admin-outlet'
  s.add_dependency 'systemu'

end