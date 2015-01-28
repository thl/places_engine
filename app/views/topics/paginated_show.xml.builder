xml.instruct!
xml.topic do
  xml.current_page(@features.current_page, type: 'integer')
  xml.total_pages(@features.total_pages, type: 'integer')
  xml.per_page(@features.per_page, type: 'integer')
  xml.total_entries(@features.total_entries, type: 'integer')
  xml.features(:type => 'array') do
    xml << render(:partial => 'features/brief_feature.xml.builder', :collection => @features, :as => :feature) if !@features.empty?
  end
end