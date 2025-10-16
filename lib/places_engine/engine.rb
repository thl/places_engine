module PlacesEngine
  class Engine < ::Rails::Engine
    config.to_prepare do
      # Extending / overriding kmaps_engine controllers
      require_dependency 'admin/citations_controller'
      require_dependency 'places_engine/admin_citations_controller_extensions'
      Admin::CitationsController.include PlacesEngine::AdminCitationsControllerExtensions
      
      require_dependency 'admin/notes_controller'
      require_dependency 'places_engine/admin_notes_controller_extensions'
      Admin::NotesController.include PlacesEngine::AdminNotesControllerExtensions
      
      require_dependency 'citations_controller'
      require_dependency 'places_engine/citations_controller_extensions'
      CitationsController.include PlacesEngine::CitationsControllerExtensions
      
      require_dependency 'features_controller'
      require_dependency 'places_engine/features_controller_extensions'
      FeaturesController.include PlacesEngine::FeaturesControllerExtensions
      
      require_dependency 'notes_controller'
      require_dependency 'places_engine/notes_controller_extensions'
      NotesController.include PlacesEngine::NotesControllerExtensions
      
      require_dependency 'sessions_controller'
      require_dependency 'places_engine/sessions_controller_extensions'
      SessionsController.include PlacesEngine::SessionsControllerExtensions
      
      # Extending / overriding kmaps_engine models
      require_dependency 'feature'
      require_dependency 'places_engine/for_name_positioning'
      require_dependency 'places_engine/feature_extensions'
      require_dependency 'places_engine/feature_overrides'
      Feature.include PlacesEngine::ForNamePositioning
      Feature.include PlacesEngine::FeatureExtensions
      Feature.prepend PlacesEngine::FeatureOverrides
      
      require_dependency 'feature_relation'
      require_dependency 'places_engine/feature_relation_extensions'
      FeatureRelation.include PlacesEngine::FeatureRelationExtensions
      
      require_dependency 'illustration'
      require_dependency 'places_engine/illustration_extensions'
      Illustration.include PlacesEngine::IllustrationExtensions
    end
  end
end