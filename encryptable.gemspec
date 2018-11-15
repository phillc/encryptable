$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "encryptable/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "encryptable"
  s.version     = Encryptable::VERSION
  s.authors     = ["phillc"]
  s.email       = ["phillip@rented.com"]
  s.summary     = "Encrypt stuff"
  s.description = "Encrypt stuff"

  s.files = Dir["{app,config,db,lib}/**/*", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 5.2.0"

  s.add_development_dependency "sqlite3"
end
