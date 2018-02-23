module PlacesEngine
  class Engine < ::Rails::Engine
    initializer :assets do |config|
      Rails.application.config.assets.precompile.concat(['places_engine/inset-map.js', 'places_engine/top.js', 'places_engine/THLWMS.js',
        'places_engine/related.css'])
    end
        
    initializer :loader do |config|
      require 'places_engine/extension/feature_model'
      require 'places_engine/extension/feature_relation_model'
      require 'places_engine/extension/for_name_positioning'
      require 'places_engine/extension/illustration_model'
      require 'places_engine/extension/citations_controller'
      require 'places_engine/extension/features_controller'
      require 'places_engine/extension/notes_controller'
      require 'places_engine/extension/admin_citations_controller'
      require 'places_engine/extension/admin_notes_controller'

      Feature.send :include, PlacesEngine::Extension::ForNamePositioning
      Feature.send :include, PlacesEngine::Extension::FeatureModel
      FeatureRelation.send :include, PlacesEngine::Extension::FeatureRelationModel
      Illustration.send :include, PlacesEngine::Extension::IllustrationModel
      CitationsController.send :include, PlacesEngine::Extension::CitationsController
      FeaturesController.send :include, PlacesEngine::Extension::FeaturesController
      NotesController.send :include, PlacesEngine::Extension::NotesController
      Admin::CitationsController.send :include, PlacesEngine::Extension::AdminCitationsController
      Admin::NotesController.send :include, PlacesEngine::Extension::AdminNotesController
    end
    
    initializer :places_sweepers do |config|
      sweeper_folder = File.join('..', '..', 'app', 'sweepers')
      require_relative File.join(sweeper_folder, 'cached_category_count_sweeper')
      require_relative File.join(sweeper_folder, 'location_sweeper')
      Rails.application.config.active_record.observers = :cached_category_count_sweeper
    end
  end
end
