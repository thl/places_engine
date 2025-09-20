ActiveSupport.on_load(:admin_citations_controller) do
  require_dependency 'places_engine/admin_citations_controller_extensions'
  include PlacesEngine::AdminCitationsControllerExtensions
end

ActiveSupport.on_load(:admin_notes_controller) do
  require_dependency 'places_engine/admin_notes_controller_extensions'
  include PlacesEngine::AdminNotesControllerExtensions
end

ActiveSupport.on_load(:citations_controller) do
  require_dependency 'places_engine/citations_controller_extensions'
  include PlacesEngine::CitationsControllerExtensions
end

ActiveSupport.on_load(:features_controller) do
  require_dependency 'places_engine/features_controller_extensions'
  include PlacesEngine::FeaturesControllerExtensions
end

ActiveSupport.on_load(:notes_controller) do
  require_dependency 'places_engine/notes_controller_extensions'
  include PlacesEngine::NotesControllerExtensions
end

ActiveSupport.on_load(:sessions_controller) do
  require_dependency 'places_engine/sessions_controller_extensions'
  include PlacesEngine::SessionsControllerExtensions
end

ActiveSupport.on_load(:feature) do
  require_dependency 'places_engine/for_name_positioning'
  require_dependency 'places_engine/feature_extensions'
  require_dependency 'places_engine/feature_overrides'
  include PlacesEngine::ForNamePositioning
  include PlacesEngine::FeatureExtensions
  prepend PlacesEngine::FeatureOverrides
end

ActiveSupport.on_load(:feature_relation) do
  require_dependency 'places_engine/feature_relation_extensions'
  include PlacesEngine::FeatureRelationExtensions
end

ActiveSupport.on_load(:illustration) do
  require_dependency 'places_engine/illustration_extensions'
  include PlacesEngine::IllustrationExtensions
end