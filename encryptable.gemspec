$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "encryptable/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "encryptable"
  s.version     = Encryptable::VERSION
  s.authors     = ["phillc"]
  s.email       = ["spyyderz@gmail.com"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of Encryptable."
  s.description = "TODO: Description of Encryptable."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 5.2.0"

  s.add_development_dependency "sqlite3"
end
