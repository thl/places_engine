# The following is performed because the name expression returns nil for Feature.find(15512)
name = feature.prioritized_name(@view || current_view)
header = name.nil? ? feature.pid : name.name
xml.feature(:id => feature.id, :fid => feature.pid, :header => header) do
  types = feature.object_types
  xml.feature_types { types.each { |type| xml.feature_type(type.title) if !type.nil? } } if !types.nil? && !types.empty?
  xml.has_shapes(feature.shapes.empty? ? 0 : 1)
  xml.created_at(feature.created_at, :type => 'datetime')
  xml.updated_at(feature.updated_at, :type => 'datetime')
end