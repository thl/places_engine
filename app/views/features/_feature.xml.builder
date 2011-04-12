# The following is performed because the name expression returns nil for Feature.find(15512)
name = feature.prioritized_name(@view || current_view)
header = name.nil? ? feature.pid : name.name
xml.feature(:id => feature.id, :pid => feature.pid, :fid => feature.fid, :header => header) do
  feature.object_types.each { |type| xml.feature_type(:title => type.title, :id => type.id) }
  xml.has_shapes(feature.shapes.empty? ? 0 : 1)
  xml.created_at(feature.created_at, :type => 'datetime')
  xml.updated_at(feature.updated_at, :type => 'datetime')
  xml.related_feature_count(feature.relations.size.to_s, :type => 'integer')
  xml.description_count(feature.descriptions.size.to_s, :type => 'integer')
end