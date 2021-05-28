# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'knife-ionoscloud/version'

Gem::Specification.new do |spec|
  spec.name          = 'knife-ionoscloud'
  spec.version       = Knife::Ionoscloud::VERSION
  spec.authors       = ['IONOS Cloud']
  spec.email         = ['sdk@cloud.ionos.com']
  spec.summary       = 'Chef Knife plugin for Ionoscloud platform'
  spec.description   = 'Official Chef Knife plugin for Ionoscloud platform using REST API'
  spec.homepage      = 'https://github.com/ionos-cloud/knife-ionos-cloud'
  spec.license       = 'Apache-2.0'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'chef', '~> 16.10', '>= 16.10.17'
  spec.add_runtime_dependency 'ionoscloud', '~> 6.0'

  spec.add_development_dependency 'rspec', '~> 3.10'
  spec.add_development_dependency 'simplecov', '~> 0.21.2'
end
