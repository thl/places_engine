ActiveSupport.on_load(:feature) do
  require 'places_engine/extension/for_name_positioning'
  require 'places_engine/extension/feature_model'
  include PlacesEngine::Extension::ForNamePositioning
  include PlacesEngine::Extension::FeatureModel
  
end
ActiveSupport.on_load(:feature_relation) do
  require 'places_engine/extension/feature_relation_model'
  include PlacesEngine::Extension::FeatureRelationModel

end
ActiveSupport.on_load(:illustration) do
  require 'places_engine/extension/illustration_model'
  include PlacesEngine::Extension::IllustrationModel
end
ActiveSupport.on_load(:citations_controller) do
  require 'places_engine/extension/citations_controller'
  include PlacesEngine::Extension::CitationsController
end
ActiveSupport.on_load(:features_controller) do
  require 'places_engine/extension/features_controller'
  include PlacesEngine::Extension::FeaturesController
  
end
ActiveSupport.on_load(:notes_controller) do
  require 'places_engine/extension/notes_controller'
  include PlacesEngine::Extension::NotesController
end
ActiveSupport.on_load(:admin_citations_controller) do
  require 'places_engine/extension/admin_citations_controller'
  include PlacesEngine::Extension::AdminCitationsController
end
ActiveSupport.on_load(:admin_notes_controller) do
  require 'places_engine/extension/admin_notes_controller'
  include PlacesEngine::Extension::AdminNotesController
end