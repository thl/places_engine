$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "places_engine/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "places_engine"
  s.version     = PlacesEngine::VERSION
  s.authors     = ["Andres Montano"]
  s.email       = ["amontano@virginia.edu"]
  s.homepage    = "http://places.kmaps.virginia.edu"
  s.summary     = "Engine that provides functionality for knowledge map of places."
  s.description = "Engine that provides functionality for knowledge map of places."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency 'rails', '~> 4.1.16'
  # s.add_dependency "jquery-rails"
  # s.add_dependency 'georuby'
end
