class Admin::CitationsController < ResourceController::Base
  
  belongs_to :feature, :feature_name, :feature_relation, :feature_name_relation, :feature_object_type, :feature_geo_code
  
  protected
  
  def parent_association
    @parent_object ||= parent_object
    parent_object.citations # ResourceController needs this for the parent association
  end
  
  def collection
    @parent_object ||= parent_object
    if parent?
      Citation.send(:with_scope, :find=>{:conditions=>['citable_id = ? AND citable_type = ?', @parent_object.id, @parent_object.class.to_s]}) do
        @collection = Citation.search(params[:filter], :page=>params[:page])
      end
    else
      @collection = Citation.search(params[:filter], :page=>params[:page])
    end
  end
  
end