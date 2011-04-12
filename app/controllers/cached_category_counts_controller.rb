class CachedCategoryCountsController < ApplicationController
  caches_page :index
  
  # GET /cached_category_counts.xml
  def index
    cached_category_count = CachedCategoryCount.updated_count(params[:category_id].to_i)
    respond_to do |format|
      format.xml { render :xml => [cached_category_count].to_xml }
    end
  end
end
