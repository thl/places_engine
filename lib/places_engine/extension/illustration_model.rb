module PlacesEngine
  module Extension
    module IllustrationModel
      extend ActiveSupport::Concern
      
      included do
      end
      
      def place
        pic = self.picture
        fid = pic.instance_of?(ExternalPicture) ? pic.place_id : pic.locations.first.to_i
        fid.nil? ? nil : Feature.get_by_fid(fid)
      end
            
      module ClassMethods
      end
    end
  end
end