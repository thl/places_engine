class FeatureRelation < ActiveRecord::Base
  
  extend HasTimespan
  extend IsCitable
  extend IsDateable
  extend IsNotable
  
  acts_as_family_tree :tree, :node_class=>'Feature'
  
  after_save do |record|
    [record.parent_node, record.child_node].each { |r| r.update_related_cached_feature_relation_categories if !r.nil? }
    # we could update this object's (a FeatureRelation) hierarchy but the THL Places-app doesn't use that info in any way yet
    [record.parent_node, record.child_node].each { |r| r.update_hierarchy if !r.nil? }
  end
  
  #
  #
  #
  belongs_to :perspective
  
  #
  #
  # Validation
  #
  #
  #validates_presence_of :feature_relation_type_id, :perspective_id
  validates_presence_of :perspective_id
    
  #
  # Roles are used to describe relationship other than parent and child
  # These need to be <= 20 characters, which is the length of the field in the database.
  #
  POSSIBLE_ROLES = {
    'child'=>'', # NOT saved in the role attribute
    'adjacent'=>'adjacent',
    'intersects'=>'intersects',
    'instantiation'=>'instantiation',
    'near'=>'near',
    'located'=>'located',
    'part'=>'part',
    'related'=>'related',
    'admin_seat'=>'admin_seat',
    'admin_headquarters'=>'admin_headquarters',
    'conflict'=>'conflict',
    'affiliated'=>'affiliated'
  }
  
  ROLE_LABELS={
    'parent'=>['is a','parent','of'],
    'child'=>['is','subordinate','to'],
    'adjacent'=>['is','adjacent','to'],
    'intersects'=>['intersects','with'],
    'instantiation'=>['is','an','instantiation','of'],
    'near'=>['is','near'],
    'located'=>['is','contained','by'],
    'part'=>['is','part','of'],
    'related'=>['is','related','to'],
    'admin_seat'=>['is','administrative','seat','of'],
    'admin_headquarters'=>['is','administrative','headquarters','of'],
    'conflict'=>['is','in','conflict','with'],
    'affiliated'=>['is','affiliated','with']
  }
  
  #
  # Copy ROLE_LABELS but remove parent
  #
  POSSIBLE_ROLE_LABELS=Proc.new {
    rl = {}.merge(ROLE_LABELS)
    rl.delete('parent')
    rl
  }.call
  
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
    role = role_type(node)
    other = other_node(node)
    sentence = ROLE_LABELS[role.to_s]
    return "#{node.send(attr)} #{sentence.join(' ')} #{other.send(attr)}" unless block_given?
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
  
  def self.label_of(role)
    role = 'child' if role.eql?('')
    ROLE_LABELS[role].join(' ') unless ROLE_LABELS[role].nil?
  end
  
  def self.search(filter_value, options={})
    options[:conditions] = build_like_conditions(
      %W(role parents.fid children.fid),
      filter_value
    )
    # need to do a join here (not :include) because we're searching parents and children feature.pids
    options[:joins] = 'LEFT JOIN features parents ON parents.id=feature_relations.parent_node_id
    LEFT JOIN features children ON children.id=feature_relations.child_node_id'
    paginate(options)
  end
  
end


# == Schema Info
# Schema version: 20100428184445
#
# Table name: feature_relations
#
#  id             :integer         not null, primary key
#  child_node_id  :integer         not null
#  parent_node_id :integer         not null
#  perspective_id :integer         not null
#  ancestor_ids   :string(255)
#  notes          :text
#  role           :string(20)
#  created_at     :timestamp
#  updated_at     :timestamp