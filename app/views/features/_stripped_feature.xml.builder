# The following is performed because the name expression returns nil for Feature.find(15512)
name = feature.prioritized_name(@view)
header = name.nil? ? feature.pid : name.name
xml.feature(:id => feature.fid, :db_id => feature.id, :header => header) do # , :pid => feature.pid
  feature.object_types.each { |type| xml.feature_type(:title => type.header) } #, :id => type.id
  xml.has_shapes(feature.has_shapes? ? 1 : 0, :type => 'integer')
end