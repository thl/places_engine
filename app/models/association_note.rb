class AssociationNote < Note
  attr_accessible :association_type
  belongs_to :feature, :foreign_key => "notable_id"
  
  # AssociationNote uses single-table inheritance from Note, so we need to make sure that no Notes are
  # returned by .find. 
  default_scope where('association_type IS NOT NULL')
  
  def self.find_by_object_and_association(object, association)
    self.where(:notable_type => object.class.name, :association_type => association)
  end
  
  def association_type_name
    association_type.blank? ? '' : model_display_name(association_type.tableize.singularize).humanize
  end
  
end

# == Schema Info
# Schema version: 20110923232332
#
# Table name: notes
#
#  id                :integer         not null, primary key
#  notable_id        :integer
#  note_title_id     :integer
#  association_type  :string(255)
#  content           :text
#  custom_note_title :string(255)
#  is_public         :boolean         default(TRUE)
#  notable_type      :string(255)
#  created_at        :timestamp
#  updated_at        :timestamp