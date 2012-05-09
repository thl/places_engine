class Admin::PerspectivesController < ResourceController::Base
  
  def collection
    @collection = Perspective.search(params[:filter]).page(params[:page])
  end
  
end