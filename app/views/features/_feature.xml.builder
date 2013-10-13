# The following is performed because the name expression returns nil for Feature.find(15512)
@view = View.get_by_code('roman.popular')
name = feature.prioritized_name(@view)
header = name.nil? ? feature.pid : name.name
xml.feature(:id => feature.fid, :db_id => feature.id, :header => header) do
  xml.feature_types(:type => 'array') do
    feature.object_types.each { |type| xml.feature_type(:title => type.header, :id => type.id) }
  end
  xml.category_features(:type => 'array') do
    feature.category_features.each do |association| 
      if !association.instance_of? FeatureObjectType
        xml.category_feature do
          c = association.category
          xml.category(:title => c.header, :id => c.id)
          parent = c.parent
          xml.parent(:title => parent.header, :id => parent.id)
          root = c.root
          xml.root(:title => root.header, :id => root.id)
          xml.numeric_value(association.numeric_value, :type => 'integer')
          xml.string_value(association.string_value, :type => 'string')
        end
      end
    end
  end
  xml.names(:type => 'array') do
    View.all.each do |v|
      name = feature.prioritized_name(v)
      tags = {:id => name.id, :language => name.language.code, :view => v.code, :name => name.name}
      tags[:writing_system] = name.writing_system.code if !name.writing_system.nil?
      tags[:language] = name.language.code if !name.language.nil?
      relation = name.parent_relations.first
      if !relation.nil?
        tags[:alt_spelling_system] = relation.alt_spelling_system.code if !relation.alt_spelling_system.nil?
        tags[:orthographic_system] = relation.orthographic_system.code if !relation.orthographic_system.nil?
        tags[:phonetic_system] = relation.phonetic_system.code if !relation.phonetic_system.nil?
      end
      xml.name(tags)
    end
  end
  parents = feature.all_parent_relations.collect(&:parent_node)
  xml.parents(:type => 'array') { xml << render(:partial => 'stripped_feature.xml.builder', :collection => parents, :as => :feature) if !parents.empty? }
  xml.perspectives(:type => 'array') do
    per = Perspective.get_by_code(default_perspective_code)
    hierarchy = feature.closest_ancestors_by_perspective(per)
    xml.perspective(:id => per.id, :code => per.code) do
      xml.ancestors(:type => 'array') { xml << render(:partial => 'stripped_feature.xml.builder', :collection => hierarchy, :as => :feature) if !hierarchy.empty? }
    end
    per = Perspective.get_by_code('cult.reg')
    if !per.nil?
      hierarchy = feature.closest_ancestors_by_perspective(per)
      xml.perspective(:id => per.id, :code => per.code) do
        xml.ancestors(:type => 'array') { xml << render(:partial => 'stripped_feature.xml.builder', :collection => hierarchy, :as => :feature) if !hierarchy.empty? }
      end
    end
  end
  descriptions = feature.descriptions
  xml.descriptions(:type => 'array') do
    descriptions.each do |d|
      options = {:id => d.id, :is_primary => d.is_primary}
      options[:source_url] = d.source_url if !d.source_url.blank?
      options[:title] = d.title if !d.title.blank?
      xml.description(options)
    end
  end
  xml.has_shapes(feature.has_shapes? ? 1 : 0, :type => 'integer')
  closest = feature.closest_feature_with_shapes
  closest_fid = closest.nil? ? nil : closest.fid
  xml.closest_fid_with_shapes(closest_fid, :type => 'integer')
  url = closest_fid.nil? ? nil : "#{InterfaceUtils::Server.get_url}/places/maps/interactive/#fid:#{closest_fid}"
  xml.interactive_map_url(url, :type => 'string')
  xml.created_at(feature.created_at, :type => 'datetime')
  xml.updated_at(feature.updated_at, :type => 'datetime')
  xml.related_feature_count(feature.relations.size.to_s, :type => 'integer')
  xml.description_count(feature.descriptions.size.to_s, :type => 'integer')
end