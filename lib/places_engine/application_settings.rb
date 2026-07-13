module PlacesEngine
  module ApplicationSettings
    def self.google_maps_key
      Rails.cache.fetch("application_settings/#{InterfaceUtils::Server.get_domain}/google_maps_key", :expires_in => 1.day) do
        str = InterfaceUtils::ApplicationSettings.settings['google.maps.key']
        str = nil if str.blank?
        str
      end
    end
    
  end
end

