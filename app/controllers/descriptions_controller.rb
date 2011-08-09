class DescriptionsController < ApplicationController
  caches_page :show, :index, :if => :api_response?.to_proc
  before_filter :find_feature
 
  def contract
    d = Description.find(params[:id])
    render :partial => '/descriptions/contracted', :locals => {:feature => @feature, :d => d}
  end
  
  def expand
    @d = Description.find(params[:id])
    @description =  Description.find(params[:id])
    render_descriptions
  end
  
  def index
    @descriptions = @feature.descriptions
    respond_to do |format|
      format.xml
      format.json { render :json => Hash.from_xml(render_to_string(:action => 'index.xml.builder')) }
    end
  end
  
  def show
    set_common_variables(session)
    @description = Description.find(params[:id])
    @tab_options = {:entity => @feature}
    @current_tab_id = :descriptions
    respond_to do |format|
      format.html
      format.xml
      format.json { render :json => Hash.from_xml(render_to_string(:action => 'show.xml.builder')) }
    end
  end

  private
  # This is tied to features
  def find_feature
    @feature = Feature.get_by_fid(params[:feature_id]) # Feature.find(params[:feature_id])
  end
  
  def render_descriptions
    #find a way to save selected expanded description
    render :update do |page|
	    yield(page) if block_given?
	    page.replace_html 'descriptions_div', :partial => '/descriptions/index', :locals => { :feature => @feature, :description => @d}
	  end
  end
  
  def api_response?
    request.format.xml? || request.format.json?
  end
end