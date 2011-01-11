class CitationController < ResourceController::Base
  belongs_to :altitude, :description, :category_feature, :feature_geo_code, :feature_name, :feature_name_relation, :feature_object_type, :feature_relation, :shape
  
  def index
    unless parent_object.nil?
      @citations = parent_object.citations
      @parent_object = parent_object
      render :partial => '/citations/list'
    end
  end
end
