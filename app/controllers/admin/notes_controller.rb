class Admin::NotesController < ResourceController::Base
  belongs_to :altitude, :category_feature, :description, :feature_geo_code, :feature_name, :feature_name_relation, :feature_object_type, :feature_relation, :shape, :time_unit

  before_filter :collection

  edit.before {@authors = Person.order('fullname') }

  create.wants.html { redirect_to polymorphic_url([:admin, object.notable, object]) }
  update.wants.html { redirect_to polymorphic_url([:admin, object.notable, object]) }
  destroy.wants.html { redirect_to polymorphic_url([:admin, object.notable]) }
  
  def add_author
    @authors = Person.order('fullname')
    # renders add_author.js.erb
  end
    
  protected
  
  def parent_association
    @parent_object ||= parent_object
    parent_object.notes # ResourceController needs this for the parent association
  end
  
  def collection
    @parent_object ||= parent_object
    if parent?
      Note.send(:with_scope, :find=>where(['notable_id = ? AND notable_type = ?', @parent_object.id, @parent_object.class.to_s])) do
        @collection = Note.search(params[:filter], :page=>params[:page])
      end
    else
      @collection = Note.search(params[:filter], :page=>params[:page])
    end
  end
end