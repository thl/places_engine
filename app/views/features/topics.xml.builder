xml.instruct!
xml.feature do
  xml << render(partial: 'feature_types.xml.builder', object: @feature.object_types)
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
          values = []
          values << association.string_value if !association.string_value.blank?
          values << association.numeric_value if !association.numeric_value.nil?
          stack = association.category_stack
          display = stack.join(' > ')
          display << ": #{values.join(', ')}" if !values.empty?
          xml.display_string(display)
        end
      end
    end
  end
end