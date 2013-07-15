module PlacesEngine
  module Extension
    module AdminNotesController
      extend ActiveSupport::Concern

      included do
        belongs_to :altitude, :category_feature, :feature_object_type, :shape
      end
    end
  end
end