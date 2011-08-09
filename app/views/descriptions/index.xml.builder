xml.descriptions do
  xml << render(:partial => 'description.xml.builder', :collection => @descriptions) if !@descriptions.empty?
end