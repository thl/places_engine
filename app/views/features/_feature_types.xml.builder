xml.feature_types(:type => 'array') do
  feature_types.each { |type| xml.feature_type(:title => type.header, :id => type.id) }
end
