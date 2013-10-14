module PlacesEngine
  module Extension
    module IllustrationModel
      include ActionView::Helpers
      include ActionDispatch::Routing
      include Rails.application.routes.url_helpers
      extend ActiveSupport::Concern
      
      included do
      end
      
      def place
        fid = self.picture.place_id
        fid.nil? ? nil : Feature.get_by_fid(fid)
      end
            
      module ClassMethods
      end
    end
  end
end