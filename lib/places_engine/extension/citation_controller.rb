module PlacesEngine
  module Extension
    module CitationController
      extend ActiveSupport::Concern

      included do
        belongs_to :altitude, :shape
      end
    end
  end
end