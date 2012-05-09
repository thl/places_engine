class Admin::FeatureGeoCodesController < ResourceController::Base
  belongs_to :feature
  
  protected
  
  def parent_association
    @parent_object ||= parent_object
    @parent_object.geo_codes
  end
  
  def collection
    @parent_object ||= parent_object
    feature_id=params[:feature_id]
    search_results = FeatureGeoCode.search(params[:filter])
    search_results = search_results.where(['feature_id = ?', feature_id]) if feature_id
    @collection = search_results.page(params[:page])
  end  
end