module PlacesEngine
  module AdminNotesControllerExtensions
    extend ActiveSupport::Concern

    included do
      belongs_to :description, :feature_geo_code, :feature_name, :feature_name_relation, :feature_relation, :time_unit, :altitude, :category_feature, :feature_object_type, :shape
    end
  end
end