# The following is performed because the name expression returns nil for Feature.find(15512)
view = View.get_by_code('roman.popular')
name = feature.prioritized_name(view)
header = name.nil? ? feature.pid : name.name
xml.feature(:id => feature.id, :pid => feature.pid, :fid => feature.fid, :header => header) do
  feature.object_types.each { |type| xml.feature_type(:title => type.title, :id => type.id) }
  feature.category_features.each do |association| 
    if !association.instance_of? FeatureObjectType
      xml.category_feature do
        c = association.category
        xml.category(:title => c.title, :id => c.id)
        parent = c.parent
        xml.parent(:title => parent.title, :id => parent.id)
        root = c.root
        xml.root(:title => root.title, :id => root.id)
        xml.numeric_value(association.numeric_value, :type => 'integer')
        xml.string_value(association.string_value, :type => 'string')
      end
    end
  end
  View.all.each do |v|
    name = feature.prioritized_name(v)
    tags = {:id => name.id, :language => name.language.code, :view => v.code}
    tags[:writing_system] = name.writing_system.code if !name.writing_system.nil?
    tags[:language] = name.language.code if !name.language.nil?
    relation = name.parent_relations.first
    if !relation.nil?
      tags[:alt_spelling_system] = relation.alt_spelling_system.code if !relation.alt_spelling_system.nil?
      tags[:orthographic_system] = relation.orthographic_system.code if !relation.orthographic_system.nil?
      tags[:phonetic_system] = relation.phonetic_system.code if !relation.phonetic_system.nil?
    end
    xml.name(name.name, tags)
  end
  feature.all_parent_relations.each do |r|
    parent = r.parent_node
    name = parent.prioritized_name(view)
    header = name.nil? ? parent.pid : name.name
    xml.parent_relation do
      xml.feature(:id => parent.id, :pid => parent.pid, :fid => parent.fid, :header => header, :perspective => r.perspective.code)
      parent.object_types.each { |type| xml.feature_type(:title => type.title, :id => type.id) }
    end
  end
  descriptions = feature.descriptions
  if !descriptions.empty?
    descriptions.each do |d|
      options = {:id => d.id, :is_primary => d.is_primary}
      options[:source_url] = d.source_url if !d.source_url.blank?
      options[:title] = d.title if !d.title.blank?
      xml.description(options)
    end
  end
  xml.has_shapes(feature.shapes.empty? ? 0 : 1)
  xml.created_at(feature.created_at, :type => 'datetime')
  xml.updated_at(feature.updated_at, :type => 'datetime')
  xml.related_feature_count(feature.relations.size.to_s, :type => 'integer')
  xml.description_count(feature.descriptions.size.to_s, :type => 'integer')
end