# The following is performed because the name expression returns nil for Feature.find(15512)
name = feature.prioritized_name(@view)
header = name.nil? ? feature.pid : name.name
xml.feature(id: feature.fid, db_id: feature.id, header: header) do # , :pid => feature.pid
  xml.feature_types(type: 'array') do
    feature.object_types.each { |type| xml.feature_type(id: type.id, title: type.header) } #, :id => type.id
  end
  xml.has_shapes(feature.has_shapes? ? 1 : 0, :type => 'integer')
  xml << render(partial: 'relation.xml.builder', object: relation) if defined? relation
end