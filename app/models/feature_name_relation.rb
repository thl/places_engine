# == Schema Information
# Schema version: 20091102185045
#
# Table name: feature_name_relations
#
#  id                     :integer         not null, primary key
#  child_node_id          :integer         not null
#  parent_node_id         :integer         not null
#  ancestor_ids           :string(255)
#  is_phonetic            :integer
#  is_orthographic        :integer
#  is_translation         :integer
#  is_alt_spelling        :integer
#  phonetic_system_id     :integer
#  orthographic_system_id :integer
#  alt_spelling_system_id :integer
#  created_at             :timestamp
#  updated_at             :timestamp
#

class FeatureNameRelation < ActiveRecord::Base
  
  acts_as_family_tree :tree, :node_class=>'FeatureName'
  
  after_save do |record|
    # we could update this object's (a FeatureRelation) hierarchy but the THL Places-app doesn't use that info in any way yet
    [record.parent_node, record.child_node].each {|r| r.update_hierarchy }
    feature = record.feature
    feature.update_name_positions
    feature.update_cached_feature_names
  end
  
  #TYPES=[
  #  
  #]
  
  #
  #
  # Associations
  #
  #
  extend HasTimespan
  extend IsCitable
  extend IsNotable
  
  belongs_to :perspective
  belongs_to :phonetic_system
  belongs_to :alt_spelling_system
  belongs_to :orthographic_system
  
  def to_s
    "\"#{child_node}\" relation to \"#{parent_node}\""
  end
  
  def display_string
    return "phonetic-#{phonetic_system.name.downcase}" unless phonetic_system.blank?
    return "orthographic-#{orthographic_system.name.downcase}" unless orthographic_system.blank?
    return "alt-spelling-#{alt_spelling_system.name.downcase}" unless alt_spelling_system.blank?
    return "translation" unless is_translation.blank?
    "Unknown Relation"
  end
  
  def pp_display_string
    return "Transcription-#{phonetic_system.name}" unless phonetic_system.blank?
    return "Transliteration-#{orthographic_system.name}" unless orthographic_system.blank?
    return "Alt Spelling-#{alt_spelling_system.name}" unless alt_spelling_system.blank?
    return "Translation" unless is_translation.blank?
    "Unknown Relation"
  end
  
  #
  # Returns the feature that owns this FeatureNameRelation
  #
  def feature
    child_node.feature
  end
  
  def self.search(filter_value, options={})
    options[:conditions] = build_like_conditions(
      %W(children.name parents.name),
      filter_value
    )
    options[:joins] = 'LEFT JOIN feature_names parents ON parents.id=feature_name_relations.parent_node_id
    LEFT JOIN feature_names children ON children.id=feature_name_relations.child_node_id'
    paginate(options)
  end
  
end