class Admin::FeaturesController < ResourceController::Base
  cache_sweeper :feature_sweeper, :only => [:update, :destroy]
  
  destroy.before { Rails.cache.write('fid', params[:id]) }
  new_action.before { @object.fid = Feature.generate_pid }
  create.before { @object.is_blank = false }
  update.before { update_primary_description; Rails.cache.write('fid', params[:id]) }
  
  before_filter :collection, :only=>:locate_for_relation
  
  def locate_for_relation
    @locating_relation=true
    # Remove the Feature that is currently looking for a relation
    # (shouldn't be possible to relate to itself)
    @collection.delete object
    render :action=>:index
  end
  
  def set_primary_description
    @feature = Feature.find(params[:id])
    #render :action => 'primary_description_set'
  end
  
  def clone
    redirect_to admin_feature_url(Feature.find(params[:id]).clone_with_names)
  end
  
  private
  
  def collection
    filter = params[:filter]
    context_id = params[:context_id]
    page = params[:page]
    unless context_id.blank?
      @context_feature, @collection = Feature.contextual_search(context_id, filter, :page=>page)
    else
      @collection = Feature.search(filter, :page=>page)
    end
  end
  
  def update_primary_description
      if !params[:primary].nil? 
        feat = Feature.find(params[:id])
        primary_desc = Description.find(params[:primary])
        feat.descriptions.update_all("is_primary = false")
        feat.descriptions.update_all("is_primary = true","id=#{primary_desc.id}")
      end
  end  
end