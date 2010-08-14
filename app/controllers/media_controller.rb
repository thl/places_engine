class MediaController < ApplicationController
  # GET /media/1
  # GET /media/1.xml
  def show
    @medium = Medium.find(params[:id])
    @features = Feature.find_all_by_medium_id(@medium.id)
    @title = "Features Associated to Medium #{@medium.id}"
    respond_to do |format|
      format.html { render :template => 'features/list' } # show.html.erb
    end
  end
end
