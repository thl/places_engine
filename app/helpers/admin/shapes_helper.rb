module Admin::ShapesHelper
  def feature_shapes_link(feature=nil)
    feature.nil? ? link_to('feature shapes', admin_feature_shapes_path) : link_to('shapes', admin_feature_shapes_path(feature))
  end
  
  def shape_display_string(shape)
    return shape.geo_type unless shape.is_point?
    return "Latitude: #{shape.lat}; Longitude: #{shape.lng}"
  end
  
  def google_maps_key
    InterfaceUtils::Server.environment == InterfaceUtils::Server::EBHUTAN ? 'ABQIAAAA-y3Dt_UxbO4KSyjAYViOChQYlycRhKSCRlUWwdm5YkcOv9JZvxQ7K1N-weCz0Vvcplc8v8TOVZ4lEQ' : 'ABQIAAAAmlH3GDvD6dTOdZjfrfvLFxTkTKGJ2QQt6wuPk9SnktO8U_sCzxTyz_WwKoSJx63MPLV9q8gn8KCNtg'
  end
end