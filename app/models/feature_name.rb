# == Schema Information
# Schema version: 20091102185045
#
# Table name: feature_names
#
#  id                          :integer         not null, primary key
#  feature_id                  :integer         not null
#  name                        :string(255)     not null
#  feature_name_type_id        :integer
#  ancestor_ids                :string(255)
#  position                    :integer         default(0)
#  etymology                   :text
#  writing_system_id           :integer
#  language_id                 :integer         not null
#  created_at                  :timestamp
#  updated_at                  :timestamp
#  is_primary_for_romanization :boolean
#

class FeatureName < ActiveRecord::Base
  
  acts_as_family_tree :node, :tree_class=>'FeatureNameRelation'
  
  # after_save :init_timespan
  after_save { |record| record.feature.update_cached_feature_names} #{ |record| record.update_hierarchy }
  
  after_create do |record|
    feature = record.feature
    feature.update_name_positions
  end
  
  # acts_as_solr
  
  extend HasTimespan
  extend IsCitable
  extend IsNotable
  
  #
  # Associations
  #
  
  belongs_to :feature
  belongs_to :language
  belongs_to :writing_system
  belongs_to :type, :class_name=>'FeatureNameType', :foreign_key=>:feature_name_type_id
  belongs_to :info_source
  has_many :cached_feature_names
  
  #
  #
  # Validation
  #
  #
  validates_presence_of :feature_id, :name, :language_id
  validates_numericality_of :position
  
  def is_current?
    self.timespan.is_current
  end
  
  
  def to_s
    name
  end
  
  def display_string
    return 'Original' if is_original?
    parent_relations.first.display_string
  end
  
  def pp_display_string
    return 'Original' if is_original?
    parent_relations.first.pp_display_string
  end
  
  def is_original?
    relations.empty? or parent_relations.empty?
  end
  
  def in_western_language?
    Language.is_western_id? self[:language_id]
  end
  
  def in_language_without_transcription_system?
    Language.lacks_transcription_system_id? self.id
  end
  
  #
  # Defines Comparable module's <=> method
  #
  def <=>(object)
    return -1 if object.language.nil?
    # Put Chinese when sorting
    return -1 if object.language.code == 'chi'
    return 1 if object.language.code == 'eng'
    return self.name <=> object.name
  end
  
  def self.search(filter_value, options={})
    options[:conditions] = build_like_conditions(
      %W(feature_names.name feature_names.etymology),
      filter_value
    )
    paginate(options)
  end  
end
