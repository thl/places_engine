# The following is performed because the name expression returns nil for Feature.find(15512)
@view = View.get_by_code('roman.popular')
name = feature.prioritized_name(@view)
header = name.nil? ? feature.pid : name.name
xml.feature(:id => feature.fid, :db_id => feature.id, :header => header) do
  xml << render(:partial => 'feature_types.xml.builder', :object => feature.object_types)
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
  children = feature.all_child_relations.collect(&:child_node)
  xml.children(:type => 'array') { xml << render(:partial => 'stripped_feature.xml.builder', :collection => children, :as => :feature) if !children.empty? }
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
  captions = feature.captions
  xml.captions(:type => 'array') do
    captions.each do |c|
      options = {:id => c.id, :language => c.language.code, :content => c.content }
      xml.caption(options)
    end
  end
  summaries = feature.summaries
  xml.summaries(:type => 'array') do
    summaries.each do |c|
      xml.summary do
        xml.id(c.id, :type => 'integer')
        xml.language(c.language.code)
        xml.content(c.content)
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
  xml.illustrations(:type => 'array') do
    feature.illustrations.each do |illustration|
      picture = illustration.picture
      options = {:id => picture.id}
      if picture.instance_of?(MmsIntegration::Picture)
        options[:url] = MmsIntegration::Medium.element_url(picture.id, :format => params['format'])
        options[:type] = 'mms'
      else
        options[:width] = picture.width
        options[:height] = picture.height
        options[:url] = picture.url
        options[:type] = 'external'
      end
      xml.picture(options)
    end
  end
  xml.has_shapes(feature.has_shapes? ? 1 : 0, :type => 'integer')
  xml.has_altitudes(feature.altitudes.count>0 ? 1 : 0, :type => 'integer')
  closest = feature.closest_feature_with_shapes
  closest_fid = closest.nil? ? nil : closest.fid
  xml.closest_fid_with_shapes(closest_fid, :type => 'integer')
  url = closest_fid.nil? ? nil : "#{InterfaceUtils::Server.get_url}/places/maps/interactive/#fid:#{closest_fid}"
  xml.interactive_map_url(url, :type => 'string')
  url = closest_fid.nil? ? nil : gis_resources_url(:fids => closest_fid, :format => 'kmz')
  xml.kmz_url(url, :type => 'string')
  xml.associated_resources do
    xml.etymology_count(feature.names.where(['etymology <> ?', '']).count.to_s, :type => 'integer')
    xml.related_feature_count(feature.relations.size.to_s, :type => 'integer')
    xml.description_count(feature.descriptions.size.to_s, :type => 'integer')
    xml.subject_count(feature.category_count.to_s, :type => 'integer')
    xml.picture_count(feature.media_count(:type => 'Picture').to_s, :type => 'integer')
    xml.video_count(feature.media_count(:type => 'Video').to_s, :type => 'integer')
    xml.document_count(feature.media_count(:type => 'Document').to_s, :type => 'integer')
  end
  xml.created_at(feature.created_at, :type => 'datetime')
  xml.updated_at(feature.updated_at, :type => 'datetime')
end