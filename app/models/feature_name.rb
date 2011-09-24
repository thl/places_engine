class FeatureName < ActiveRecord::Base
  attr_accessor :skip_update
  acts_as_family_tree :node, :tree_class=>'FeatureNameRelation'
  
  after_save do |record|
    feature = record.feature
    Rails.cache.write('tree_tmp', ( feature.parent.nil? ? feature.id : feature.parent.id))
    if !record.skip_update
      feature.update_cached_feature_names
      feature.touch
   end
  end #{ |record| record.update_hierarchy
  
  # Too much for the importer to deal with!
  #after_destroy do |record|
  #  feature = record.feature
  #  feature.update_cached_feature_names
  #  feature.touch
  #end
  
  after_create do |record|
    if !record.skip_update
      record.feature.update_name_positions
    end
  end
  
  # acts_as_solr
  
  extend HasTimespan
  extend IsCitable
  extend IsDateable
  extend IsNotable
  
  #
  # Associations
  #
  
  belongs_to :feature
  belongs_to :language
  belongs_to :writing_system
  belongs_to :type, :class_name=>'FeatureNameType', :foreign_key=>:feature_name_type_id
  belongs_to :info_source, :class_name => 'Document'
  has_many :cached_feature_names
  
  #
  #
  # Validation
  #
  #
  validates_presence_of :feature_id, :name, :language_id
  validates_numericality_of :position
  
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

# == Schema Info
# Schema version: 20110923232332
#
# Table name: feature_names
#
#  id                          :integer         not null, primary key
#  feature_id                  :integer         not null
#  feature_name_type_id        :integer
#  language_id                 :integer         not null
#  writing_system_id           :integer
#  ancestor_ids                :string(255)
#  etymology                   :text
#  is_primary_for_romanization :boolean
#  name                        :string(255)     not null
#  position                    :integer         default(0)
#  created_at                  :timestamp
#  updated_at                  :timestamp