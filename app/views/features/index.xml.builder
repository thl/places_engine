xml.features do
  xml << render(:partial => 'features/feature.xml.builder', :collection => @features) if !@features.empty?
end