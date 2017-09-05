require 'places_engine/engine'
require 'places_engine/configuration'

I18n.load_path += Dir[File.join(__dir__, '..', 'config', 'locales', '**', '*.yml')]

module PlacesEngine
end
