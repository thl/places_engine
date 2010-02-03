xml.features(:page => params[:page] || 1, :total_pages => WillPaginate::ViewHelpers.total_pages_for_collection(@features)) do
  xml << render(:partial => 'feature.xml.builder', :collection => @features) if !@features.empty?
end