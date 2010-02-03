xml.features do
  xml << render(:partial => 'feature.xml.builder', :collection => @features) if !@features.empty?
end