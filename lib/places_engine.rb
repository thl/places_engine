require 'places_engine/engine'
require 'active_record_ext'
require 'array_ext'
require 'csv'
require 'feature_extension_for_name_positioning'
require 'has_timespan'
require 'is_citable'
require 'is_notable'
require 'session_manager'
require 'simple_prop_cache'
require 'contextual_tree_builder'
require 'simple_props_controller_helper'
require 'feature_pid_generator'

I18n.load_path += Dir[File.join(File.dirname(__FILE__), '..', 'config', 'locales', '**', '*.yml')]

module PlacesEngine
end
