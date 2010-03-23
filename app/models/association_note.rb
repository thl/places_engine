# == Schema Information
#
# Table name: notes
#
#  id                :integer         not null, primary key
#  notable_type      :string(255)
#  notable_id        :integer
#  note_title_id     :integer
#  custom_note_title :string(255)
#  content           :text
#  created_at        :timestamp
#  updated_at        :timestamp
#  association_type  :string(255)
#

class AssociationNote < Note
  belongs_to :feature, :foreign_key => "notable_id"
  
  # AssociationNote uses single-table inheritance from Note, so we need to make sure that no Notes are
  # returned by .find. 
  default_scope :conditions => "association_type IS NOT NULL"
  
  def self.find_by_object_and_association(object, association)
    self.find(:all, :conditions => {:notable_type => object.class.name, :association_type => association})
  end
  
  def association_type_name
    self.association_type.blank? ? '' : self.association_type.tableize.humanize.downcase
  end
  
end
