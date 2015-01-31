xml.feature_types(type: 'array') do
  feature_types.each do |type|
    caption = type.caption
    xml.feature_type do
      xml.title(type.header)
      xml.id(type.id, type: 'integer')
      xml.caption(caption.nil? ? nil : caption.content)
      xml.ancestors { type.ancestors.each { |ancestor| xml.feature_type(title: ancestor.header, id: ancestor.id) } }
    end
  end
end
