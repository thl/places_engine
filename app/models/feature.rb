class Feature < ActiveRecord::Base
  attr_accessor :skip_update
  
  include FeatureExtensionForNamePositioning
  extend IsDateable
  
  validates_presence_of :fid
  validates_uniqueness_of :fid
  validates_numericality_of :position, :allow_nil=>true
  
  after_destroy do |r|
    if !r.skip_update
      node = r.parent.nil? ? r : r.parent
      node.expire_children_cache
    end
  end
  
  # after_update do |r|
  #   node = r.parent.nil? ? r : r.parent
  #   node.expire_children_cache
  # end
  
  # acts_as_solr :fields=>[:pid]
  
  acts_as_family_tree :node, :tree_class => 'FeatureRelation', :conditions => {'feature_relations.feature_relation_type_id' => FeatureRelationType.hierarchy_ids}
  # These are distinct from acts_as_family_tree's parent/child_relations, which only include hierarchical parent/child relations.
  has_many :all_child_relations, :class_name => 'FeatureRelation', :foreign_key => 'parent_node_id', :dependent => :destroy
  has_many :all_parent_relations, :class_name => 'FeatureRelation', :foreign_key => 'child_node_id', :dependent => :destroy
  has_many :altitudes, :dependent => :destroy
  has_many :association_notes, :foreign_key => "notable_id", :dependent => :destroy
  has_many :cached_feature_names, :dependent => :destroy
  has_many :cached_feature_relation_categories, :dependent => :destroy
  has_many :category_features, :dependent => :destroy
  has_many :citations, :as => :citable, :dependent => :destroy
  has_many :contestations, :dependent => :destroy
  has_many :cumulative_category_feature_associations, :dependent => :destroy
  has_many :descriptions, :dependent => :destroy
  has_many :feature_object_types, :order => :position, :dependent => :destroy
  has_many :geo_codes, :class_name=>'FeatureGeoCode', :dependent => :destroy # naming inconsistency here (see feature_object_types association) ?
  has_many :geo_code_types, :through=>:geo_codes
  has_many :shapes, :foreign_key => 'fid', :primary_key => 'fid'
  has_one :xml_document, :class_name=>'XmlDocument', :dependent => :destroy
  
  # This fetches root *FeatureNames* (names that don't have parents),
  # within the scope of the current feature
  has_many :names, :class_name=>'FeatureName', :dependent => :destroy do
    @@associated_models = [FeatureName, FeatureObjectType, FeatureGeoCode, XmlDocument]  
    #
    #
    #
    def roots(options = {})
      # proxy_target, proxy_owner, proxy_reflection - See Rails "Association Extensions"
      if options[:conditions].nil?
        options[:conditions] = {'feature_names.feature_id'=>proxy_owner.id}
      else
        options[:conditions].merge!({'feature_names.feature_id'=>proxy_owner.id})
      end
      options[:order] ||= 'position'
      proxy_reflection.class_name.constantize.roots(options) #.sort !!! See the FeatureName.<=> method
    end
  end
  
  def has_shapes?(options = {})
    use_log_in_status = options.has_key? :logged_in?
    shapes = self.shapes
    return use_log_in_status ? (options[:logged_in?] ? !shapes.empty? : shapes.any?(&:is_public?)) : !shapes.empty?
  end
  
  # Options take :logged_in?
  def closest_feature_with_shapes(options = {})
    Rails.cache.fetch("features/#{self.fid}/closest_feature_with_shapes", :expires_in => 1.hour) do
      break self if self.has_shapes?(options)
      # check if geographical parent has shapes (township)
      geo_rel = Perspective.get_by_code('geo.rel')
      first_township_relation = self.all_parent_relations.where(:perspective_id => geo_rel.id).first
      if !first_township_relation.nil?
        node = first_township_relation.parent_node
        break node if node.has_shapes?(options)
      end
      # check if county parent has shapes (county)
      pol_admin = Perspective.get_by_code('pol.admin.hier')
      first_county_relation = self.all_parent_relations.where(:perspective_id => pol_admin.id).first
      if !first_county_relation.nil?
        node = first_county_relation.parent_node
        break node if node.has_shapes?(options)
      end
      nil
    end
  end
  
  def closest_parent_by_perspective(perspective)
    Rails.cache.fetch("features/#{self.fid}/closest_parent_by_perspective/#{perspective.id}", :expires_in => 1.hour) do
      parent_relation = FeatureRelation.where(:child_node_id => self.id, :perspective_id => perspective.id, :feature_relation_type_id => FeatureRelationType.hierarchy_ids).select('parent_node_id').first
      break parent_relation.parent_node if !parent_relation.nil?
      parent_relation = FeatureRelation.where(:child_node_id => self.id, :perspective_id => perspective.id).select('parent_node_id').first
      break parent_relation.parent_node if !parent_relation.nil?
      parent_relation = FeatureRelation.where(:child_node_id => self.id).select('parent_node_id').first
      break parent_relation.parent_node if !parent_relation.nil?
      nil
    end
  end
  
  def closest_hierarchical_feature_id_by_perspective(perspective)
    Rails.cache.fetch("features/#{self.fid}/closest_hierarchical_feature_by_perspective/#{perspective.id}", :expires_in => 1.hour) do
      ancestor_ids = self.closest_ancestors_by_perspective(perspective).collect(&:id)
      root_ids = Feature.current_roots_by_perspective(perspective).collect(&:id)
      parent_id = (root_ids & ancestor_ids).first
      break root_ids.first if parent_id.nil?
      ancestor_ids.delete(parent_id)
      relation = FeatureRelation.where(:perspective_id => perspective.id, :parent_node_id => parent_id, :child_node_id => ancestor_ids, :feature_relation_type_id => FeatureRelationType.hierarchy_ids).first
      while !relation.nil?
        ancestor_ids.delete(parent_id)
        parent_id = relation.child_node_id
        relation = FeatureRelation.where(:perspective_id => perspective.id, :parent_node_id => parent_id, :child_node_id => ancestor_ids, :feature_relation_type_id => FeatureRelationType.hierarchy_ids).first
      end
      parent_id
    end
  end
  
  def closest_ancestors_by_perspective(perspective)
    Rails.cache.fetch("features/#{self.fid}/closest_ancestors_by_perspective/#{perspective.id}", :expires_in => 1.hour) do
      current = self
      stack = []
      begin
        stack.push(current)
        current = current.closest_parent_by_perspective(perspective)
      end while !current.nil?
      stack.reverse
    end
  end
  
  #
  #
  #
  def self.current_roots(current_perspective, current_view)
    Rails.cache.fetch("features/current_roots/#{current_perspective.id}/#{current_view.id}", :expires_in => 1.day) do
      joins(:cached_feature_names => :feature_name).where(:is_blank => false, :cached_feature_names => {:view_id => current_view.id}).order('feature_names.name').roots.find_all do |r|
#      with_scope(:find => includes(:cached_feature_names => :feature_name).where(:is_blank => false, :cached_feature_names => {:view_id => current_view.id}).order('feature_names.name')) do
 #       roots.find_all do |r|
          # if ANY of the child relations are current, return true to nab this Feature
          r.child_relations.any? {|cr| cr.perspective==current_perspective }
        end
    #  end
    end
  end

  def self.current_roots_by_perspective(current_perspective)
    Rails.cache.fetch("features/current_roots/#{current_perspective.id}", :expires_in => 1.day) do
      with_scope(:find => where('features.is_blank' => false)) do
        roots.select do |r|
          # if ANY of the child relations are current, return true to nab this Feature
          r.child_relations.any? {|cr| cr.perspective==current_perspective }
        end
      end
    end
  end

  #
  #
  #
  def current_children(current_perspective, current_view)
    return children.includes(:cached_feature_names => :feature_name).where('cached_feature_names.view_id' => current_view.id).order('feature_names.name').select do |c| # children(:include => [:names, :parent_relations])
      c.parent_relations.any? {|cr| cr.perspective==current_perspective}
    end
  end
  
  def all_descendants_by_topic(topic_ids)
    pending = [self.id]
    des = []
    while !pending.empty?
      e = pending.pop
      FeatureRelation.all(:select => 'child_node_id', :conditions => {:parent_node_id => e}).each do |r|
        c = r.child_node_id
        if !des.include? c
          des << c
          pending.push(c)
        end
      end
    end
    topic_ids = topic_ids.first if topic_ids.size==1
    des.select{ |f_id| !CumulativeCategoryFeatureAssociation.first(:conditions => {:category_id => topic_ids, :feature_id => f_id}).nil? }.collect{|f_id| Feature.find(f_id)}
  end
    
  def descendants_by_perspective(perspective)
    pending = [self]
    des = [self]
    des_ids = [self.id]
    while !pending.empty?
      e = pending.pop
      FeatureRelation.all(:select => 'child_node_id', :conditions => {:parent_node_id => e.id, :perspective_id => perspective.id, :feature_relation_type_id => FeatureRelationType.hierarchy_ids}).each do |r|
        c = r.child_node
        if !des_ids.include? c.id
          des_ids << c.id
          des << c
          pending.push(c)
        end
      end
    end
    des
  end
  
  #
  #
  #
  def current_parent(current_perspective, current_view)
    current_parents(current_perspective, current_view).first
  end
  
  #
  #
  #
  def current_parents(current_perspective, current_view)
    return parents.includes(:cached_feature_names => :feature_name).where('cached_feature_names.view_id' => current_view.id).order('feature_names.name').select do |c| # parents(:include => [:names, :child_relations])
      c.child_relations.any? {|cr| cr.perspective==current_perspective}
    end
  end
  
  #
  #
  #
  def current_siblings(current_perspective, current_view)
    # if this feature doesn't have parent_relations, it's a root node. then return root nodes minus this feature
    # if thie feature DOES have parent relations, get the parent children, minus this feature
    (parent_relations.empty? ? self.class.current_roots(current_perspective, current_view) : current_parents(current_perspective, current_view).map(&:children).flatten.uniq) - [self]
  end
  
  #
  #
  #
  def current_ancestors(current_perspective)
    return ancestors.select do |c|
      c.child_relations.any? {|cr| cr.perspective==current_perspective}
    end
  end
  
  #
  # This is distinct from acts_as_family_tree's relations method, which only finds hierarchical child and parent relations.
  #
  def all_relations
    FeatureRelation.where(['child_node_id = ? OR parent_node_id = ?', id, id])
  end
  
  def feature_relations
    all_relations
  end
    
  #
  #
  #
  def to_s
    self.name
  end
  
  def pid
    "F#{self.fid}"
  end
  
  #
  #
  #
  def self.generate_pid
    FeaturePidGenerator.next
  end
  
  #
  # given a "context_id" (Feature.id), this method only searches
  # the context's descendants. It returns an array
  # where the first element is the context Feature
  # and the second element is the collection of matching descendants.
  #
  # context_id - the id of a Feature
  # filter - any string filter value
  # options - the standard find(:all) options
  #
  def self.contextual_search(string_context_id, filter, options={}, search_options={})
    context_id = string_context_id.to_i # for some reason this parameter has been especially susceptible to SQL injection attack payload
    if context_id.blank?
      conditions = true
    else
      conditions = [
        '(features.id = ? OR features.ancestor_ids LIKE ?)',
        context_id,
        "%.#{context_id}.%"
      ]
    end
    
    base_scope = conditions
    results = with_scope(:find=>where(base_scope)) do
      self.search(filter, options, search_options)
    end
    # the context feature might not be returned
    # use detect to find a feature.id match against the context_id
    # if it isn't found, just do a standard find:
    context_feature = results.detect {|i| i.id.to_s==context_id} || find(context_id) rescue nil
    [context_feature, results]
  end
  
  # 
  # A basic search method that uses a single value for filtering on multiple columns
  # filter_value is used as the value to filter on
  # options - the standard arguments sent to ActiveRecord::Base.paginate (WillPaginate gem)
  # See http://api.rubyonrails.com/classes/ActiveRecord/Base.html#M001416
  # 
  def self.search(filter_value, options={}, search_options={})
    # Setup the base rules
    if search_options[:scope] && search_options[:scope] == 'name'
      conditions = build_like_conditions(%W(feature_names.name), filter_value, {:match => search_options[:match]})
    else
      conditions = build_like_conditions(%W(descriptions.content feature_names.name), filter_value, {:match => search_options[:match]})
    end
    if !conditions.blank?
      fid = filter_value.gsub(/[^\d]/, '')
      if !fid.blank?
        conditions[0] << ' OR features.fid = ?'
        conditions << fid.to_i
      end
    end
    base_includes = [:names, :descriptions]
    base_order = 'features.position'
    # Now that we have the base scope setup, apply the custom options and paginate!
    # For :has_descriptions == true, it appears that there isn't a way to use IS NOT NULL in a :conditions hash, so
    # we'll use it in a :conditions string in an outer scope.  Is there a way to use IS NOT NULL in
    # base_scope[:conditions] instead?
    if !search_options[:has_descriptions].nil? && search_options[:has_descriptions]
      with_scope(:find => where('descriptions.content IS NOT NULL')) do
        with_scope(:find=>where(conditions).includes(base_includes).order(base_order)) { options.has_key?(:page) ? paginate(options) : self.all(options) }
      end
    # Otherwise, just use a single scope:
    else
      with_scope(:find=>where(conditions).includes(base_includes).order(base_order)) { options.has_key?(:page) ? paginate(options) : self.all(options) }
    end
  end
  
  def self.name_search(filter_value)
    Feature.includes(:names).where(['features.is_public = ? AND feature_names.name ILIKE ?', 1, "%#{filter_value}%"]).order('features.position')
  end
  
  #
  # Shortcut for getting all feature_object_types.object_types
  #
  def object_types
    feature_object_types.collect(&:category).select{|c| c}
  end
  
  def category_count
    CategoryFeature.count(:conditions => {:feature_id => self.id})
  end
  
  def media_count(options = {})
    media_count_hash = Rails.cache.fetch("#{self.cache_key}/media_count", :expires_in => 1.day) do
      media_place_count = MediaPlaceCount.find(:all, :params => {:place_id => self.fid}).dup
      media_count_hash = { 'Medium' => media_place_count.shift.count.to_i }
      media_place_count.each{|count| media_count_hash[count.medium_type] = count.count.to_i }
      media_count_hash
    end
    type = options[:type]
    return type.nil? ? media_count_hash['Medium'] : media_count_hash[type]
  end
  
  def kmaps_url
    TopicalMapResource.get_url + place_path
  end

  def media_url
    MediaManagementResource.get_url + place_path
  end

  def pictures_url
    MediaManagementResource.get_url + place_path('pictures')
  end

  def videos_url
    MediaManagementResource.get_url + place_path('videos')
  end

  def documents_url
    MediaManagementResource.get_url + place_path('documents')
  end
  
  #
  # Find all features that are related through a FeatureRelation
  #
  def related_features
    relations.collect{|relation| relation.parent_node_id == self.id ? relation.child_node : relation.parent_node}
  end
  
  #= Shapes ==============================
  # A Feature has_many Shapes
  # A Shape belongs_to (a) Feature
  
  def self.find_by_shape(shape)
    Feature.get_by_fid(shape.fid)
  end
    
  def associated?
    @@associated_models.any?{|model| model.find_by_feature_id(self.id)} || !Shape.get_by_fid(self.fid).nil?
  end
  
  def self.blank
    Feature.all.reject{|f| f.associated? }
  end
  
  def self.associated
    Feature.all.select{|f| f.associated? }
  end
  
  def self.get_by_fid(fid)
    Rails.cache.fetch("features-fid/#{fid}", :expires_in => 1.hour) do
      begin
        self.find_by_fid(fid)
      rescue ActiveRecord::ActiveRecordError
        nil
      end      
    end
  end
    
  def association_notes_for(association_type, options={})
    conditions = {:notable_type => self.class.name, :notable_id => self.id, :association_type => association_type, :is_public => true}
    conditions.delete(:is_public) if !options[:include_private].nil? && options[:include_private] == true
    AssociationNote.where(conditions)
  end
    
  def update_object_type_positions
    feature_object_types.where(:position => 0).order('created_at').inject(feature_object_types.maximum(:position)+1) do |pos, fot|
      fot.update_attribute(:position, pos)
      pos + 1
    end
  end
  
  def update_shape_positions
    shapes.reject{|shape| shape.position != 0}.inject(shapes.max{|a,b|a.position <=> b.position}.position+1) do |pos, shape|
      shape.update_attribute(:position, pos)
      pos + 1
    end
  end

  def update_cached_feature_relation_categories
    CachedFeatureRelationCategory.destroy_all(:feature_id => self.id)
    CachedFeatureRelationCategory.destroy_all(:related_feature_id => self.id)
 	
  	self.all_relations.each do |relation|
  		relation.child_node.feature_object_types.each do |fot|
  		  CachedFeatureRelationCategory.create({
  		    :feature_id => relation.parent_node_id,
  		    :related_feature_id => relation.child_node_id,
  		    :category_id => fot.category_id,
  		    :feature_relation_type_id => relation.feature_relation_type_id,
  		    :feature_is_parent => true,
  		    :perspective_id => relation.perspective_id
  		  })
  		end
  		parent_node = relation.parent_node
  		if !parent_node.nil?
  		  parent_node.feature_object_types.each do |fot|
    		  CachedFeatureRelationCategory.create({
    		    :feature_id => relation.child_node_id,
    		    :related_feature_id => relation.parent_node_id,
    		    :category_id => fot.category_id,
    		    :feature_relation_type_id => relation.feature_relation_type_id,
    		    :feature_is_parent => false,
    		    :perspective_id => relation.perspective_id
    		  })
    		end
		  end
  	end
  end
  
  def clone_with_names
    new_feature = Feature.create(:fid => Feature.generate_pid, :is_blank => false, :is_public => true, :skip_update => true)
    names = self.names
    names_to_clones = Hash.new
    names.each do |name|
      cloned = name.clone
      cloned.feature = new_feature
      cloned.skip_update = true
      cloned.save
      names_to_clones[name.id] = cloned
    end
    relations = Array.new
    names.each { |name| name.relations.each { |relation| relations << relation if !relations.include? relation } }
    relations.each do |relation|
      new_relation = relation.clone
      new_relation.child_node = names_to_clones[new_relation.child_node.id]
      new_relation.parent_node = names_to_clones[new_relation.parent_node.id]
      new_relation.skip_update = true
      new_relation.save
    end
    new_feature.update_name_positions
    new_feature.update_cached_feature_names
    names.each{ |name| name.update_hierarchy }
    return new_feature
  end
  
  def expire_children_cache
    # Avoiding "regular expression too big" error by slicing node up
    descendants.collect(&:id).push(id).each_slice(1000) do |nodes|
      next if nodes.blank?
      ActionController::Base.new.expire_fragment(Regexp.new("/views/tree/.*/node_id_(#{nodes.join('|')}).*"))
    end
  end
  
  def expire_tree_cache
    node = self.parent.nil? ? self : self.parent
    node.expire_children_cache
  end
      
  private
  
  def self.name_search_options(filter_value, options = {})
    
  end
  
  def place_path(type = nil)
    a = ['places', self.fid]
    a << type if !type.nil?
    a.join('/')
  end
end

# == Schema Info
# Schema version: 20110923232332
#
# Table name: features
#
#  id                         :integer         not null, primary key
#  ancestor_ids               :string(255)
#  fid                        :integer         not null
#  is_blank                   :boolean         not null
#  is_name_position_overriden :boolean         not null
#  is_public                  :integer(2)
#  old_pid                    :string(255)
#  position                   :integer         default(0)
#  created_at                 :datetime
#  updated_at                 :datetime