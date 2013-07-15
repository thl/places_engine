module PlacesEngine
  module Extension
    module AdminCitationController
      extend ActiveSupport::Concern

      included do
        belongs_to :altitude, :category_feature, :feature_object_type
      end
    end
  end
end