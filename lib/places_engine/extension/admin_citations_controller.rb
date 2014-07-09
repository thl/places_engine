module PlacesEngine
  module Extension
    module AdminCitationsController
      extend ActiveSupport::Concern

      included do
        belongs_to :description, :feature, :feature_name, :feature_relation, :feature_name_relation, :feature_geo_code, :altitude, :category_feature, :feature_object_type
      end
    end
  end
end