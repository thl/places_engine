module Admin::ShapesHelper
  def feature_shapes_link(feature=nil)
    feature.nil? ? link_to('feature shapes', admin_feature_shapes_path) : link_to('shapes', admin_feature_shapes_path(feature))
  end
  
  def shape_display_string(shape)
    return shape.geo_type unless shape.is_point?
    return "Latitude: #{shape.lat}; Longitude: #{shape.lng}"
  end
end