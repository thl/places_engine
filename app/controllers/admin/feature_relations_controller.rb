class Admin::FeatureRelationsController < ResourceController::Base
  
  belongs_to :feature
  
  new_action.before {|c| c.send :setup_for_new_relation}
  
  private
  
  def collection
    @parent_object = parent_object # ResourceController normally sets this
    feature_id = params[:feature_id]
    filter = params[:filter]
    page = params[:page]
    if feature_id
      @collection = FeatureRelation.send(:with_scope, :find=>{:conditions=>['parent_node_id = ? OR child_node_id = ?', feature_id, feature_id]}) do
        FeatureRelation.search(filter, :page=>page)
      end
    else
      @collection = FeatureRelation.search(filter, :page=>page)
    end
  end
  
  #
  # Need to override the ResourceController::Helpers.parent_association method
  # to get the correct name of the parent association
  # Reminder: This is a subclass of ResourceController::Base
  #
  def parent_association
    @parent_object=parent_object # ResourceController normally sets this
    if params[:id].nil?
      return parent_object.parent_relations 
    end
    # Gotta find it seperately, will get a recursive stack error elsewise
    o = FeatureRelation.find(params[:id])
    parent_object.id == o.parent_node.id ? parent_object.child_relations : parent_object.parent_relations
  end
  
  def setup_for_new_relation
    object.child_node = parent_object # ResourceController can't seem to set this up?
    object.parent_node = Feature.find(params[:target_id])
  end
  
end