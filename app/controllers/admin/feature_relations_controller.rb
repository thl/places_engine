class Admin::FeatureRelationsController < ResourceController::Base
  
  belongs_to :feature
  
  new_action.before {|c| c.send :setup_for_new_relation}
  #create.before :process_feature_relation_type_id_mark
  update.before :process_feature_relation_type_id_mark

  #
  # The create.before wasn't being called (couldn't figure out why not; update.before works
  # fine), so create is done manually for now. This should be fixed.  
  #
  def create
    process_feature_relation_type_id_mark
    @object = FeatureRelation.new(params[:feature_relation])

    respond_to do |format|
      if @object.save
        flash[:notice] = 'Feature Relation was successfully created.'
        format.html { redirect_to(polymorphic_url [:admin, parent_object, object]) }
        format.xml  { render :xml => @object, :status => :created, :location => @object }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @object.errors, :status => :unprocessable_entity }
      end
    end
  end
  
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
      return parent_object.all_parent_relations 
    end
    # Gotta find it seperately, will get a recursive stack error elsewise
    o = FeatureRelation.find(params[:id])
    parent_object.id == o.parent_node.id ? parent_object.all_child_relations : parent_object.all_parent_relations
  end
  
  def setup_for_new_relation
    object.child_node = parent_object # ResourceController can't seem to set this up?
    object.parent_node = Feature.find(params[:target_id])
  end
  
  def process_feature_relation_type_id_mark
    if params[:feature_relation][:feature_relation_type_id_] =~ /^_/
      params[:feature_relation][:child_node_id] = object.parent_node_id
      params[:feature_relation][:parent_node_id] = object.child_node_id
    end
    params[:feature_relation][:feature_relation_type_id] = params[:feature_relation][:feature_relation_type_id_].gsub(/^_/, '')
    params[:feature_relation].delete(:feature_relation_type_id_)
  end
  
end
