xml.instruct!
xml.feature do
  xml << render(partial: 'feature_types.xml.builder', object: @feature.feature_object_types)
  xml.category_features(type: 'array') do
    @feature.category_features.order(:position).each do |association| 
      if !association.instance_of? FeatureObjectType
        xml.category_feature do
          c = association.category
          caption = c.caption
          xml.category(title: c.header, id: c.id, caption: caption.nil? ? nil : caption.content)
          perspective = association.perspective
          xml.perspective(perspective.code) if !perspective.nil?
          xml.label(association.label)
          xml.prefix_label(association.prefix_label, type: 'boolean')
          xml.show_parent(association.show_parent, type: 'boolean')
          xml.show_root(association.show_root, type: 'boolean')
          parent = c.parent
          caption = parent.caption
          xml.parent(title: parent.header, id: parent.id, caption: caption.nil? ? nil : caption.content)
          root = c.sub_root
          caption = root.caption
          xml.root(title: root.header, id: root.id, caption: caption.nil? ? nil : caption.content)
          xml.numeric_value(association.numeric_value, type: 'integer')
          xml.string_value(association.string_value, type: 'string')
          xml.display_string(association.display_string)
          xml << render(partial: 'time_units/index.xml.builder', locals: {time_units: association.time_units})
          xml << render(partial: 'citations/index.xml.builder', locals: {citations: association.citations})
          xml << render(partial: 'notes/index.xml.builder', locals: {notes: association.notes})
        end
      end
    end
  end
end