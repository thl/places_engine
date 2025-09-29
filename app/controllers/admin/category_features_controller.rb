class Admin::CategoryFeaturesController < ApplicationController
  allow_unauthenticated_access only: %i[ index show ]
  include KmapsEngine::ResourceObjectAuthentication
  resource_controller
  
  cache_sweeper :category_feature_sweeper, :only => [:update, :destroy]
  
  belongs_to :feature
  
  def collection
    filter = params[:filter]
    search_results = parent? ? CategoryFeature.contextual_search(filter, parent_object.id) : CategoryFeature.search(filter)
    @collection = search_results.page(params[:page])
  end
  
  protected
  
  # Only allow a trusted parameter "white list" through.
  def category_feature_params
    params.require(:category_feature).permit(:prefix_label, :label, :string_value, :numeric_value, :show_parent, :category_id, :show_root)
  end
  
  private
  
  def build_object
    if object_params.nil?
      @object ||= end_of_association_chain.send :build
    else
      @object ||= end_of_association_chain.send :build, object_params
    end
  end
end
