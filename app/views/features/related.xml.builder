@view = View.get_by_code(default_view_code)
per = Perspective.get_by_code(default_perspective_code)
xml.instruct!
relations = @feature.cached_feature_relation_categories.select('feature_relation_type_id, feature_is_parent, COUNT(DISTINCT related_feature_id) AS count').group('feature_relation_type_id, feature_is_parent').order('feature_relation_type_id, feature_is_parent')
xml.feature_relation_types(type: 'array') do
  relations.each do |relation|
    rt = relation.feature_relation_type
    xml.feature_relation_type do
      xml.id(rt.id, type: 'integer')
      is_parent = relation.feature_is_parent?
      xml.label(is_parent ? rt.label : rt.asymmetric_label)
      xml.code(is_parent ? rt.asymmetric_code : rt.code)
      xml.count(relation.count)
      category_relations = @feature.cached_feature_relation_categories.select('category_id, COUNT(DISTINCT category_id) AS count').group('category_id').where(feature_relation_type_id: rt.id, feature_is_parent: is_parent).sort_by { |cr| cr.category.header }
      xml.categories(type: 'array') do
        category_relations.each do |cr|
          category = cr.category
          xml.category do
            xml.id(category.id, type: 'integer')
            xml.header(category.header)
            caption = category.caption
            xml.caption(caption&.content)
            xml.ancestors { category.ancestors.each { |ancestor| xml.feature_type(title: ancestor.header, id: ancestor.id) } }
            xml.count(cr.count, type: 'integer')
            features = @feature.cached_feature_relation_categories.select('related_feature_id').where(feature_relation_type_id: rt.id, feature_is_parent: is_parent, category_id: category.id).collect(&:related_feature)
            xml.features(type: 'array') do
              features.each do |feature|
                xml.feature do
                  xml.id(feature.fid, type: 'integer')
                  xml.db_id(feature.id, type: 'integer')
                  name = feature.prioritized_name(@view)
                  xml.header(name.nil? ? feature.pid : name.name)
                  caption = feature.caption
                  xml.caption(caption&.content)
                  xml.ancestors(type: 'array') do
                    hierarchy = feature.closest_ancestors_by_perspective(per)
                    hierarchy.each do |ancestor|
                      n = ancestor.prioritized_name(@view)
                      xml.feature(id: ancestor.fid, header: n.nil? ? ancestor.pid : n.name)
                    end
                  end
                end
              end
            end if !features.empty?
          end
        end
      end
    end
  end
end