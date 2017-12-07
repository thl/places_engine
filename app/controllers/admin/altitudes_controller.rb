class Admin::AltitudesController < ResourceController::Base
  include KmapsEngine::ResourceObjectAuthentication
  
  cache_sweeper :location_sweeper, :only => [:update, :destroy]
  
  belongs_to :feature
  
  # create.wants.html { redirect_to polymorphic_url([:admin, object.feature]) }
  #update.wants.html { redirect_to polymorphic_url([:admin, object.feature]) }
  #destroy.wants.html { redirect_to polymorphic_url([:admin, object.feature]) }
  update.wants.html { redirect_to admin_feature_url(object.feature.fid) }
  destroy.wants.html { redirect_to admin_feature_url(object.feature.fid) }
  
  protected
  
  def parent_association
    parent_object.altitudes # ResourceController needs this for the parent association
  end
  
  def collection
    @collection = Altitude.where(:feature_id => parent_object.id).page(params[:page])
  end
  
  # Only allow a trusted parameter "white list" through.
  def altitude_params
    params.require(:altitude).permit(:average, :estimate, :minimum, :maximum, :unit_id)
  end
end
