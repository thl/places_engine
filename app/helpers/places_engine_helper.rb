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
end
