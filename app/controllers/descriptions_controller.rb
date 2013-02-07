class DescriptionsController < ApplicationController
  caches_page :show, :index, :if => Proc.new { |c| c.request.format.xml? }
  before_filter :find_feature
 
  def contract
    d = Description.find(params[:id])
    render :partial => '/descriptions/contracted', :locals => {:feature => @feature, :d => d}
  end
  
  # renders expand.js.erb
  def expand
    @d = Description.find(params[:id])
    @description =  Description.find(params[:id])    
  end
  
  def index
    @descriptions = @feature.descriptions
    respond_to do |format|
      format.xml
      format.json { render :json => Hash.from_xml(render_to_string(:action => 'index.xml.builder')), :callback => params[:callback] }
    end
  end
  
  def show
    if @feature.nil?
      redirect_to features_url
    else
      set_common_variables(session)
      @description = Description.find(params[:id])
      @tab_options = {:entity => @feature}
      @current_tab_id = :descriptions
      respond_to do |format|
        format.html
        format.xml
        format.json { render :json => Hash.from_xml(render_to_string(:action => 'show.xml.builder')), :callback => params[:callback] }
      end
    end
  end

  private
  # This is tied to features
  def find_feature
    @feature = Feature.get_by_fid(params[:feature_id]) # Feature.find(params[:feature_id])
  end
end