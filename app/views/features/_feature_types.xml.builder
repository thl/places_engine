xml.feature_types(type: 'array') do
  feature_types.each do |feature_type|
    type = feature_type.category
    caption = type.caption
    xml.feature_type do
      xml.title(type.header)
      xml.id(type.id, type: 'integer')
      xml.caption(caption&.content)
      xml.ancestors { type.ancestors.each { |ancestor| xml.feature_type(title: ancestor.header, id: ancestor.id) } }
      xml << render(partial: 'time_units/index', formats: [:xml], locals: {time_units: feature_type.time_units})
      xml << render(partial: 'citations/index', formats: [:xml], locals: {citations: feature_type.citations})
      xml << render(partial: 'notes/index', formats: [:xml], locals: {notes: feature_type.notes})
    end
  end
end
