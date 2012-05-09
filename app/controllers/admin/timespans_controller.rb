class Admin::TimespansController < ResourceController::Base
  
  def collection
    @collection = Timespan.search(params[:filter]).page(params[:page])
  end
  
end