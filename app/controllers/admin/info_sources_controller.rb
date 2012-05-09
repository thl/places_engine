class Admin::InfoSourcesController < ResourceController::Base
  def collection
    @collection = InfoSource.search(params[:filter]).page(params[:page]).order('UPPER(code)')
  end
end