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
    if feature_id
      @collection = FeatureGeoCode.send(:with_scope, :find=>where(['feature_id = ?', feature_id])) do
        FeatureGeoCode.search(params[:filter], :page=>params[:page])
      end
    else
      @collection = FeatureGeoCode.search(params[:filter], :page=>params[:page])
    end
  end
  
end