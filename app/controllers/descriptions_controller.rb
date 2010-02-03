class DescriptionsController < ApplicationController
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

  private
  # This is tied to features
  def find_feature
    @feature = Feature.find(params[:feature_id])
  end
    
   
  def render_descriptions
    #find a way to save selected expanded description
    render :update do |page|
	    yield(page) if block_given?
	    page.replace_html 'descriptions_div', :partial => '/descriptions/index', :locals => { :feature => @feature, :description => @d}
	  end
  end

end
