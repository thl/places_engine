xml.features(:page => params[:page] || 1, :total_pages => WillPaginate::ViewHelpers.total_pages_for_collection(@features)) do
  xml << render(:partial => 'stripped_feature.xml.builder', :collection => @features, :as => :feature) if !@features.empty?
end