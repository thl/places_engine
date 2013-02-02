class Note < ActiveRecord::Base
  # Included for use of model_display_name in notable_type_name.  Is there
  # a better approach to this?
  include ApplicationHelper
  
  attr_accessible :custom_note_title, :note_title_id, :content, :is_public, :id, :author_ids
  belongs_to :notable, :polymorphic=>true
  belongs_to :note_title
  has_and_belongs_to_many :authors, :class_name => 'AuthenticatedSystem::Person', :join_table => 'authors_notes', :association_foreign_key => 'author_id'
  accepts_nested_attributes_for :authors
  
  before_save :determine_title
  
  # AssociationNote uses single-table inheritance from Note, so we need to make sure that no AssociationNotes are
  # returned by .find. 
  default_scope where(:association_type => nil)
  
  def title
    self.custom_note_title.blank? ? (self.note_title.nil? ? nil : self.note_title.title) : self.custom_note_title
  end
  
  def notable_type_name
    notable_type.blank? ? '' : model_display_name(notable_type.tableize.singularize)
  end
  
  def to_s
    return self.title.nil? ? "Note" : self.title.to_s
  end
  
  def self.search(filter_value)
    self.where(build_like_conditions(%W(notes.content notes.custom_note_title note_titles.title), filter_value)).includes(:note_title)
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