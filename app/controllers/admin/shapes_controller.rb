class Admin::ShapesController < ResourceController::Base
  include KmapsEngine::ResourceObjectAuthentication
  
  cache_sweeper :feature_sweeper, :only => [:update, :destroy]
  cache_sweeper :location_sweeper, :only => [:update, :destroy]
  
  belongs_to :feature
  
  def update
    load_object
    geo = @object.geometry
    geo.y = params[:shape][:lat] if !params[:shape][:lat].blank? && params[:shape][:lat].to_f > 0.0
    geo.x = params[:shape][:lng] if !params[:shape][:lng].blank? && params[:shape][:lng].to_f > 0.0
    @object.geometry = geo
    @object.altitude = params[:shape][:altitude]
    if @object.save
      set_flash :update
    else
      set_flash :update_fails
    end
    redirect_to collection_path
  end

  def create
    # Specify the SRID as 4326
    y = params[:shape][:lat] if !params[:shape][:lat].blank? && params[:shape][:lat].to_f > 0.0
    x = params[:shape][:lng] if !params[:shape][:lng].blank? && params[:shape][:lng].to_f > 0.0
    @object = Shape.new(fid: params[:shape][:fid], altitude: params[:shape][:altitude])
    if @object.save
      Shape.where(gid: @object.gid).update_all("geometry = ST_SetSRID(ST_Point(#{x}, #{y}),4326)")
      set_flash :create
    else
      set_flash :create_fails
    end
    redirect_to collection_path
  end

  
  # update.response do | wants |
  #   wants.html { redirect_to collection_path }
  # end

  def prioritize
    @feature = Feature.find(params[:id])
  end
  
  def set_priorities
    feature = Feature.find(params[:id])
    feature.shapes.each { |shape| shape.update_attribute(:position, params['feature_shape'].index(shape.id.to_s) + 1) }
    render :nothing => true
  end
  
  protected
  
    #def object
    #  @object = Shape.find(params[:id])
    #  @object
    #end
    
    # def parent_association
    #   if params[:id].nil?
    #     return parent_object.parent_relations
    #   end
    #   # Gotta find it seperately, will get a recursive stack error elsewise
    #   o = Shape.find(params[:id])
    #   parent_object.id == o.parent_node.id ? parent_object.child_relations : parent_object.parent_relations
    # end

    def collection
      @collection = Feature.find(params[:feature_id]).shapes
    end
end
