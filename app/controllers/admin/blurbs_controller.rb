class Admin::BlurbsController < ResourceController::Base
  
  def collection
    @collection = Blurb.search(params[:filter]).page(params[:page])
  end
    
end
