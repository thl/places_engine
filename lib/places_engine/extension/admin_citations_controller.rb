module PlacesEngine
  module Extension
    module AdminCitationController
      extend ActiveSupport::Concern

      included do
        belongs_to :altitude
      end
    end
  end
end