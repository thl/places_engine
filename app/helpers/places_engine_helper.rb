# Methods added to this helper will be available to all templates in the application.
module PlacesEngineHelper
  def custom_secondary_tabs_list
    # The :index values are necessary for this hash's elements to be sorted properly
    {
      :place => {:index => 1, :title => Feature.model_name.human.titleize, :shanticon => 'overview'},
      :descriptions => {:index => 2, :title => 'Essays', :shanticon => 'texts'},
      :related => {:index => 3, :title => 'Related', :shanticon => 'places'}
    }
  end
  
  def kmaps_url(feature)
    topic_path(feature.fid)
  end
  
  def topical_map_url(feature)
    topics_feature_path(feature.fid)
  end
  
  def geoserver_url
    case InterfaceUtils::Server.environment
    when InterfaceUtils::Server::DEVELOPMENT
      return 'http://dev.thlib.org:8080/thlib-geoserver'
    when InterfaceUtils::Server::LOCAL
      return 'http://localhost:8080/geoserver'
    else
      return 'http://www.thlib.org:8080/thdl-geoserver'
    end
  end
end
