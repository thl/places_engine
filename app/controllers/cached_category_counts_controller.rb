class CachedCategoryCountsController < ApplicationController
  caches_page :index
  
  # GET /cached_category_counts.json
  def index
    cached_category_count = CachedCategoryCount.updated_count(params[:category_id].to_i)
    respond_to do |format|
      format.json { render json: [cached_category_count].to_json }
    end
  end
end
