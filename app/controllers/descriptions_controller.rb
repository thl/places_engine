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
  
  def show
    set_common_variables(session)
    @description = Description.find(params[:id])
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
    
  # This is duplicate code from FeaturesController.  Is there a better way to share this method?
  def set_common_variables(session_params)
    
    session[:interface] ||= {}
    
    # Allow for views and perspectives to be set by GET params.  It might be possible to simplify this code...
    if params[:perspective_id] || params[:view_id]
      session = Session.new
      if params[:perspective_id]
        session.perspective_id = params[:perspective_id]
        self.current_perspective = Perspective.find(params[:perspective_id])
      end
      if params[:view_id]
        session.view_id = params[:view_id]
        self.current_view = View.find(params[:view_id])
      end
    end

    @top_level_nodes = Feature.current_roots(current_perspective, current_view)
    @session = Session.new(:perspective_id => self.current_perspective.id, :view_id => self.current_view.id)
    @perspectives = Perspective.find_all_public
    @views = View.find(:all, :order => 'name')

    # These are used for the "Characteristics" field in the search
    @kmaps_characteristics = CategoryFeature.find(:all, :select => "DISTINCT category_id", :conditions => "type IS NULL")

    search_defaults = {
    	:filter => '',
    	:scope => 'full_text',
    	:match => 'contains',
    	:search_scope => 'global',
    	:has_descriptions => '0'
    }
    
    # These are used to show the same search results that were on the previous page.
    @previous_search_params = session_params[:interface][:search_params] || search_defaults
    
    # These are used to show the same search form field values that were on the previous page.
    @search_form_params = search_defaults
  end

end
