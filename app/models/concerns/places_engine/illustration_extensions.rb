module PlacesEngine
  module IllustrationExtensions
    extend ActiveSupport::Concern
    
    included do
    end
    
    def place
      pic = self.picture
      if pic.instance_of?(ExternalPicture)
        fid = pic.place_id
      elsif pic.instance_of?(MmsIntegration::Picture)
        fid = pic.locations.first
      else
        fid = nil
      end
      fid.nil? ? nil : Feature.get_by_fid(fid.to_i)
    end
          
    module ClassMethods
    end
  end
end