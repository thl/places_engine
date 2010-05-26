class NotesController < ResourceController::Base
  belongs_to :altitude, :category_feature, :feature_geo_code, :feature_name, :feature_name_relation, :feature_object_type, :feature_relation, :shape, :time_unit
  
  def index
    unless parent_object.nil?
      @notes = parent_object.notes
      @parent_object = parent_object
      render :partial => '/notes/list'
    end
  end
end
