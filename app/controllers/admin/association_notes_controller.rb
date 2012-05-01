class Admin::AssociationNotesController < ResourceController::Base
  belongs_to :feature

  before_filter :collection
  before_filter :validate_association_type, :only => [:new]

  edit.before {@authors = Person.order('fullname') }
  new_action.before do
    @object.association_type = params[:association_type]
    @object.notable_type = @parent_object.class.name
  end

  create.wants.html { redirect_to polymorphic_url([:admin, object.notable, object]) }
  update.wants.html { redirect_to polymorphic_url([:admin, object.notable, object]) }
  destroy.wants.html { redirect_to polymorphic_url([:admin, object.notable]) }
  
  # renders add_author.js.erb
  def add_author
    @authors = Person.order('fullname')
  end
  
  protected
  
  def parent_association
    @parent_object ||= parent_object
    parent_object.association_notes # ResourceController needs this for the parent association
  end
  
  def collection
    @parent_object ||= parent_object
    if parent?
      AssociationNote.send(:with_scope, :find=>where(['notable_id = ? AND notable_type = ?', @parent_object.id, @parent_object.class.to_s])) do
        @collection = AssociationNote.search(params[:filter], :page=>params[:page])
      end
    else
      @collection = AssociationNote.search(params[:filter], :page=>params[:page])
    end
  end
  
  def validate_association_type
    render :text => "Sorry, an association type hasn't been specified." and return if (
      (@object.nil? && params[:association_type].blank?) ||
      (!@object.nil? && @object.association_type.blank?))
  end
end