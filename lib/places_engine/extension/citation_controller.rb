module PlacesEngine
  module Extension
    module CitationController
      extend ActiveSupport::Concern

      included do
        belongs_to :description, :feature_geo_code, :feature_name, :feature_name_relation, :feature_relation, :altitude, :shape
      end
    end
  end
end