# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'knife-profitbricks/version'

Gem::Specification.new do |spec|
  spec.name          = "knife-profitbricks"
  spec.version       = Knife::ProfitBricks::VERSION
  spec.authors       = ["Ethan Devenport"]
  spec.email         = ["ethand@stackpointcloud.com"]
  spec.summary       = 'Chef Knife plugin for ProfitBricks platform'
  spec.description   = 'Official Chef Knife plugin for ProfitBricks platform using REST API'
  spec.homepage      = "https://github.com/ionos-cloud/knife-ionos-cloud"
  spec.license       = "Apache-2.0"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "chef", "~> 16"

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake", "~> 10.4"
  spec.add_development_dependency "rspec", "~> 3.2"
  spec.add_development_dependency "parallel_tests", "~> 1.0"
end
