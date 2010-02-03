class Admin::DescriptionsController < ResourceController::Base
  
  belongs_to :feature

  before_filter :collection

  create.before { defaults_primary }

  edit.before {@authors = User.find(:all, :order => 'fullname') }
  
  def add_author
    @authors = User.find(:all, :order => 'fullname')
    render :partial => 'authors_selector', :locals => {:selected => nil}
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
      @collection = Description.send(:with_scope, :find=>{:conditions=>['feature_id = ?', feature_id]}) do
        Description.search(params[:filter], :page=>params[:page])
      end
    else
      @collection = Description.search(params[:filter], :page=>params[:page])
    end
    
  end
  
  def defaults_primary
    if parent_object.descriptions.empty?
      object.is_primary = "true"
    end
    if object.is_primary.nil? 
      object.is_primary = "false"
    end
  end

  
end