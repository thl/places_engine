class FeatureRelationType < ActiveRecord::Base
  has_many :feature_relations, :dependent => :destroy
  
  before_save :set_asymmetric_label
  
  def set_asymmetric_label
    asymmetric_label = label if is_symmetric
  end
  
  # Creates options for a select, marking either the asymmetric label or the original label's id
  # with a prefix of "_", which can be detected and used for switching the parent and child node
  # ids if the relation being selected requires it.
  def self.marked_options(mark_asymmetric=true)
    options = []
    FeatureRelationType.find(:all, :order => :id).each do |type|
      if type.is_symmetric
        options.push([type.label, type.id])
      else
        if mark_asymmetric
          options.push([type.label, type.id], [type.asymmetric_label, "_#{type.id}"])
        else
          options.push([type.label, "_#{type.id}"], [type.asymmetric_label, type.id])
        end
      end
    end
    options
  end
  
  # This returns the id of the FeatureRelationType that should be used in acts_as_family_tree. It
  # may be better to make a dedicated, boolean "is_hierarchical" column in feature_relation_types
  # that is only set to TRUE for this type, and use that to determine which type is used.
  # This seems to be generally satisfactory for now, since a migration creates the initial
  # FeatureRelationTypes.
  def self.hierarchy_ids
    Rails.cache.fetch('feature_relation_types/hierarchical_ids') { self.all(:conditions => {:is_hierarchical => true}, :order => :id).collect(&:id) }
  end
  
  def to_s
    is_symmetric ? label : "#{label}/#{asymmetric_label}"
  end
  
  def self.search(filter_value, options={})
    options[:conditions] = build_like_conditions(
      %W(feature_relation_types.label feature_relation_types.asymmetric_label),
      filter_value
    )
    paginate(options)
  end
  
  def self.get_by_code(code)
    Rails.cache.fetch("feature_relation_types/code/#{code}") { self.find_by_code(code) }
  end
  
  def self.get_by_asymmetric_code(code)
    Rails.cache.fetch("feature_relation_types/asymmetric_code/#{code}") { self.find_by_asymmetric_code(code) }
  end
end

# == Schema Info
# Schema version: 20110923232332
#
# Table name: feature_relation_types
#
#  id               :integer         not null, primary key
#  asymmetric_code  :string(255)
#  asymmetric_label :string(255)
#  code             :string(255)     not null
#  is_hierarchical  :boolean         not null
#  is_symmetric     :boolean
#  label            :string(255)     not null
#  created_at       :datetime
#  updated_at       :datetime