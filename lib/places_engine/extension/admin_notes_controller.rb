module PlacesEngine
  module Extension
    module AdminNotesController
      extend ActiveSupport::Concern

      included do
        belongs_to :altitude, :shape
      end
    end
  end
end