class Admin::AltitudesController < ResourceController::Base
  belongs_to :feature
  
  # create.wants.html { redirect_to polymorphic_url([:admin, object.feature]) }
  update.wants.html { redirect_to polymorphic_url([:admin, object.feature]) }
  destroy.wants.html { redirect_to polymorphic_url([:admin, object.feature]) }
  
  protected
  
  def parent_association
    @parent_object ||= parent_object
    @parent_object.altitudes # ResourceController needs this for the parent association
  end
  
  def collection
    @parent_object ||= parent_object
    @collection = Altitude.paginate(:conditions => {:feature_id => @parent_object.id}, :page => params[:page])
  end
end