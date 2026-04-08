Gem::Specification.new do |spec|
  spec.name          = "filterable"
  spec.version       = "0.1.0"
  spec.authors       = ["MasterBranch Software, LLC"]
  spec.email         = ["ray@masterbranchsoftware.com"]
  spec.summary       = "Scope-based filtering for ActiveRecord models."
  spec.description   = "A lightweight ActiveRecord concern that lets you combine named scopes " \
                       "into composable filter queries with AND/OR operators."
  spec.homepage      = "https://github.com/Master-Branch-Software/filterable"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 3.0"

  spec.files         = Dir["lib/**/*", "README.md", "LICENSE.txt"]
  spec.require_paths = ["lib"]

  spec.add_dependency "activerecord", ">= 6.0"
  spec.add_dependency "activesupport", ">= 6.0"

  spec.metadata["homepage_uri"]    = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
end
