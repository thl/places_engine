module PlacesEngine
  module Extension
    module CitationsController
      extend ActiveSupport::Concern

      included do
        belongs_to :caption, :description, :feature, :feature_geo_code, :feature_name, :feature_name_relation, :feature_relation, :summary, #This list comes from the CitationsController in kmaps_engine
        :altitude, :category_feature, :feature_object_type, :shape #specific to places_engine
      end
    end
  end
end
