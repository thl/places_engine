class Admin::FeatureRelationTypesController < ResourceController::Base
  #before_filter :collection
  
  create.before { @object.asymmetric_label = @object.label if @object.is_symmetric }
  update.before { @object.asymmetric_label = @object.label if @object.is_symmetric }

  create.wants.html { redirect_to polymorphic_url([:admin, @object]) }
  update.wants.html { redirect_to polymorphic_url([:admin, @object]) }
  destroy.wants.html { redirect_to admin_feature_relation_types_url }

  protected
  
  def collection
    @collection = FeatureRelationType.search(params[:filter]).page(params[:page])
  end
end