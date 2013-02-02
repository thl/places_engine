class FeatureRelation < ActiveRecord::Base
  attr_accessible :perspective_id, :parent_node_id, :child_node_id, :feature_relation_type_id, :ancestor_ids, :skip_update
  
  attr_accessor :skip_update
  
  extend HasTimespan
  extend IsCitable
  extend IsDateable
  extend IsNotable
  
  acts_as_family_tree :tree, :node_class => 'Feature', :conditions => {:feature_relation_type_id => FeatureRelationType.hierarchy_ids}
  
  after_save do |record|
    if !record.skip_update
      record.expire_cache
      [record.parent_node, record.child_node].each { |r| r.update_cached_feature_relation_categories if !r.nil? }
      # we could update this object's (a FeatureRelation) hierarchy but the THL Places-app doesn't use that info in any way yet
      [record.parent_node, record.child_node].each { |r| r.update_hierarchy if !r.nil? }
    end
  end
  
  before_destroy do |r|
    if !r.skip_update
      r.expire_cache
    end
  end
  
  after_destroy do |record|
    [record.parent_node, record.child_node].each { |r| r.update_cached_feature_relation_categories if !r.nil? }
  end  
  #
  #
  #
  belongs_to :perspective
  belongs_to :feature_relation_type
  
  #
  #
  # Validation
  #
  #
  #validates_presence_of :feature_relation_type_id, :perspective_id
  validates_presence_of :perspective_id
  validates_presence_of :feature_relation_type_id
  
  def role
    super.to_s
  end
  
  #
  # Returns the type of role a node plays within this relation
  #
  def role_type(node)
    raise 'Invalid node value' if node.class != Feature
    return self.role unless self.role.to_s.empty?
    self.child_node?(node) ? 'child' : 'parent'
  end
  
  #
  # Returns a sentence describing the nodes relationship to the "other"
  # Can also pass it a block to get the other node and sentence fragment
  #
  def role_of?(node, attr=:fid, &block)
    other = other_node(node)
    sentence = is_parent_node?(node) ? feature_relation_type.label : feature_relation_type.asymmetric_label
    return "#{node.send(attr)} #{sentence} #{other.send(attr)}" unless block_given?
    # yield the other node along with the sentence fragments
    yield other, sentence
  end
  
  def child_role(*args, &block)
    role_of? child_node, *args, &block
  end
  
  def parent_role(*args, &block)
    role_of? parent_node, *args, &block
  end
  
  def to_s
    "#{parent_node.fid} > #{child_node.fid}"
  end
  
  def other_node(node)
    node == self.child_node ? self.parent_node : self.child_node
  end
  
  def is_parent_node?(node)
    node == self.parent_node
  end
  
  def self.search(filter_value)
    # need to do a join here (not :include) because we're searching parents and children feature.pids
    self.where(build_like_conditions(%W(role parents.fid children.fid), filter_value)
    ).joins('LEFT JOIN features parents ON parents.id=feature_relations.parent_node_id LEFT JOIN features children ON children.id=feature_relations.child_node_id')
  end
    
  def expire_cache
    fid = Rails.cache.read('fid')
    #puts "fid from fr model: #{fid}, child_node_id: #{child_node_id}, parent_node_id = #{parent_node_id}"
    if child_node_id == fid.to_i
      Rails.cache.write('tree_tmp', parent_node_id)
      parent_node.expire_children_cache unless parent_node.nil?
    end
  end
end

# == Schema Info
# Schema version: 20110923232332
#
# Table name: feature_relations
#
#  id                       :integer         not null, primary key
#  child_node_id            :integer         not null
#  feature_relation_type_id :integer         not null
#  parent_node_id           :integer         not null
#  perspective_id           :integer         not null
#  ancestor_ids             :string(255)
#  notes                    :text
#  role                     :string(20)
#  created_at               :timestamp
#  updated_at               :timestamp