class Note < ActiveRecord::Base
  
  belongs_to :notable, :polymorphic=>true
  belongs_to :note_title
  has_and_belongs_to_many :authors, :class_name => 'User', :join_table => 'authors_notes', :association_foreign_key => 'author_id'
  
  before_save :determine_title
  
  # AssociationNote uses single-table inheritance from Note, so we need to make sure that no AssociationNotes are
  # returned by .find. 
  default_scope :conditions => {:association_type => nil}
  
  def title
    self.custom_note_title.blank? ? (self.note_title.nil? ? nil : self.note_title.title) : self.custom_note_title
  end
  
  def to_s
    return self.title.nil? ? "Note" : self.title.to_s
  end
  
  def self.search(filter_value, options={})
    options[:conditions] = build_like_conditions(
      %W(notes.content notes.custom_note_title note_titles.title),
      filter_value
    )
    options[:include] = :note_title
    paginate(options)
  end
  
  private
  
  # Notes can have one of two types of titles: a custom title, or a title from the list of note_titles.
  # When saving a note, we want only one title.  We give preference to note_title_id by setting
  # custom_note_title = "" if note_title_id is set.
  def determine_title
    unless self.note_title_id.blank?
      self.custom_note_title = ""
    end
  end
  
end

# == Schema Info
# Schema version: 20100521170006
#
# Table name: notes
#
#  id                :integer         not null, primary key
#  notable_id        :integer
#  note_title_id     :integer
#  association_type  :string(255)
#  content           :text
#  custom_note_title :string(255)
#  notable_type      :string(255)
#  created_at        :timestamp
#  updated_at        :timestamp