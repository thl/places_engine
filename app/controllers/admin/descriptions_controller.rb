class Admin::DescriptionsController < ResourceController::Base
  cache_sweeper :description_sweeper, :only => [:update, :destroy]
  belongs_to :feature
  before_filter :collection

  create.before { defaults_primary }

  edit.before {@authors = Person.find(:all, :order => 'fullname') }
  
  def add_author
    @authors = Person.find(:all, :order => 'fullname')
    render :update do |page|
      page.call "$('#update_div').before", render(:partial => 'authors_selector', :locals => {:selected => nil})
    end if request.xhr?
  end

  #def contract
  #  d = Description.find(params[:id])
  #  render :partial => 'contracted', :locals => {:feature => parent_object, :d => d}
  #end
  
  #def expand
  #  @d = Description.find(params[:id])
  #  @description =  Description.find(params[:id])
  #  render_descriptions
  #end
    
  private
  
  #def render_descriptions
  #  #find a way to save selected expanded description
  #  render :update do |page|
	#    yield(page) if block_given?
	#    page.replace_html 'descriptions_div', :partial => 'admin/descriptions/index', :locals => { :feature => parent_object, :description => @d}
	#  end
	#end
	    
  protected
  
  #
  # Override ResourceController collection method
  #
  def collection
    # needed for the list view
    @parent_object = parent_object if parent?
    
    feature_id=nil
    if params[:feature_id]
      feature_id = params[:feature_id]
    elsif params[:id]
      feature_id = object.feature_id
    end
    
    if feature_id
      @collection = Description.send(:with_scope, :find=>where(['feature_id = ?', feature_id])) { Description.search(params[:filter], :page=>params[:page]) }
    else
      @collection = Description.search(params[:filter], :page=>params[:page])
    end
  end
  
  def defaults_primary
    object.is_primary = 'true' if parent_object.descriptions.empty?
    object.is_primary = 'false' if object.is_primary.nil?
  end
end