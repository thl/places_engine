module PlacesEngine
  class Engine < ::Rails::Engine
    initializer :assets do |config|
      Rails.application.config.assets.precompile.concat(['places_engine/inset-map.js', 'places_engine/top.js'])
    end
        
    initializer :loader do |config|
      require 'places_engine/extension/feature_model'
      require 'places_engine/extension/for_name_positioning'
      require 'places_engine/extension/cached_category_count'
      require 'places_engine/extension/citation_controller'
      require 'places_engine/extension/features_controller'
      require 'places_engine/extension/notes_controller'
      require 'places_engine/extension/admin_citations_controller'
      require 'places_engine/extension/admin_notes_controller'
      
      Feature.send :include, PlacesEngine::Extension::ForNamePositioning
      Feature.send :include, PlacesEngine::Extension::FeatureModel
      CachedCategoryCount.send :extend, PlacesEngine::Extension::CachedCategoryCountExtension
      CitationController.send :include, PlacesEngine::Extension::CitationController
      FeaturesController.send :include, PlacesEngine::Extension::FeaturesController
      NotesController.send :include, PlacesEngine::Extension::NotesController
      Admin::CitationsController.send :include, PlacesEngine::Extension::AdminCitationController
      Admin::NotesController.send :include, PlacesEngine::Extension::AdminNotesController
    end
    
    initializer :places_sweepers do |config|
      sweeper_folder = File.join(File.dirname(__FILE__), '..', '..', 'app', 'sweepers')
      require File.join(sweeper_folder, 'cached_category_count_sweeper')
      Rails.application.config.active_record.observers = :cached_category_count_sweeper
    end
  end
end