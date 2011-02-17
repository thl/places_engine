class Feature < ActiveRecord::Base
  attr_accessor :skip_update
  
  include FeatureExtensionForNamePositioning
  extend IsDateable
  
  validates_presence_of :fid
  validates_uniqueness_of :fid
  validates_numericality_of :position, :allow_nil=>true

  # after_save {|record| record.update_hierarchy}  
  # acts_as_solr :fields=>[:pid]
  
  acts_as_family_tree :node, :tree_class => 'FeatureRelation', :conditions => {'feature_relations.feature_relation_type_id' => FeatureRelationType.hierarchy_ids}
  # These are distinct from acts_as_family_tree's parent/child_relations, which only include hierarchical parent/child relations.
  has_many :all_child_relations, :class_name => 'FeatureRelation', :foreign_key => 'parent_node_id', :dependent => :destroy
  has_many :all_parent_relations, :class_name => 'FeatureRelation', :foreign_key => 'child_node_id', :dependent => :destroy
  has_many :altitudes, :dependent => :destroy
  has_many :association_notes, :foreign_key => "notable_id", :dependent => :destroy
  has_many :cached_feature_names, :dependent => :destroy
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
  
  #
  #
  #
  def self.current_roots(current_perspective, current_view)
    with_scope(:find => {:include => {:cached_feature_names => :feature_name}, :conditions => {'features.is_blank' => false, 'cached_feature_names.view_id' => current_view.id}, :order => 'feature_names.name'}) do
      roots.select do |r|
        # if ANY of the child relations are current, return true to nab this Feature
        r.child_relations.any? {|cr| cr.perspective==current_perspective }
      end
    end
  end
    
  #
  #
  #
  def current_children(current_perspective, current_view)
    return children.find(:all, :include => {:cached_feature_names => :feature_name}, :conditions => {'cached_feature_names.view_id' => current_view.id}, :order => 'feature_names.name').select do |c| # children(:include => [:names, :parent_relations])
      c.parent_relations.any? {|cr| cr.perspective==current_perspective}
    end
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
    return parents.find(:all, :include => {:cached_feature_names => :feature_name}, :conditions => {'cached_feature_names.view_id' => current_view.id}, :order => 'feature_names.name').select do |c| # parents(:include => [:names, :child_relations])
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
  def current_ancestors(current_perspective, current_view)
    return ancestors(:include => {:cached_feature_names => :feature_name}, :conditions => {'cached_feature_names.view_id' => current_view.id}, :order => 'feature_names.name').select do |c|
      c.child_relations.any? {|cr| cr.perspective==current_perspective}
    end
  end
  
  #
  # This is distinct from acts_as_family_tree's relations method, which only finds hierarchical child and parent relations.
  #
  def all_relations
    FeatureRelation.find(:all, :conditions => ['child_node_id = ? OR parent_node_id = ?', id, id])
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
    
    base_scope = {
      :conditions => conditions
    }
    results = with_scope(:find=>base_scope) do
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
      conditions[0] << ' OR features.fid = ?'
      conditions << filter_value.gsub(/[^\d]/, '').to_i
    end
    
    base_scope={
      # These conditions will apply to all searches
      :conditions => conditions, :include => [:names, :descriptions], :order => 'features.position'
      #:joins => 'left join feature_names on features.id = feature_names.feature_id'
    }
    
    # Now that we have the base scope setup, apply the custom options and paginate!
    
    # For :has_descriptions == true, it appears that there isn't a way to use IS NOT NULL in a :conditions hash, so
    # we'll use it in a :conditions string in an outer scope.  Is there a way to use IS NOT NULL in
    # base_scope[:conditions] instead?
    if !search_options[:has_descriptions].nil? && search_options[:has_descriptions]
      with_scope(:find => {:conditions => "descriptions.content IS NOT NULL"}) do
        with_scope(:find=>base_scope) do
          paginate(options)
        end
      end
    # Otherwise, just use a single scope:
    else      
      with_scope(:find=>base_scope) do
        paginate(options)
      end
    end
  end
  
  def self.name_search(filter_value, options = {})
    options.merge!({:include => :names, :conditions => ['features.is_public = ? AND feature_names.name ILIKE ?', 1, "%#{filter_value}%"], :order => 'features.position'})
    Feature.find(:all, options)
  end

  def self.name_search_paginate(filter_value, options = {})
    options.merge!({:include => :names, :conditions => ['features.is_public = ? AND feature_names.name ILIKE ?', 1, "%#{filter_value}%"], :order => 'features.position'})
    Feature.paginate(options)
  end
  
  #
  # Shortcut for getting all feature_object_types.object_types
  #
  def object_types
    feature_object_types.collect(&:category).select{|c| c}
  end
  
  def categories(options = {})
    if options[:cumulative]
      return cumulative_category_feature_associations.collect(&:category).select{|c| c}
    else
      return category_features.collect(&:category).select{|c| c}
    end
  end
  
  def category_count(options = {})
    association = options[:cumulative] || false ? CumulativeCategoryFeatureAssociation : CategoryFeature
    association.count(:conditions => {:feature_id => self.id})
  end
  
  def media_count(options = {})
    media_count_hash = Rails.cache.fetch("#{self.cache_key}/media_count") do
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
    Feature.find(:all).reject{|f| f.associated? }
  end
  
  def self.associated
    Feature.find(:all).select{|f| f.associated? }
  end
  
  def self.get_by_fid(fid)
    Rails.cache.fetch("features-fid/#{fid}") do
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
    AssociationNote.find(:all, :conditions => conditions)
  end
    
  def update_object_type_positions
    feature_object_types.find(:all, :conditions => {:position => 0}, :order => 'created_at').inject(feature_object_types.maximum(:position)+1) do |pos, fot|
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
    new_feature = Feature.create(:fid => Feature.generate_pid, :is_blank => false, :is_public => true)
    names = self.names
    names_to_clones = Hash.new
    names.each do |name|
      cloned = name.clone
      cloned.feature = new_feature
      cloned.save
      names_to_clones[name.id] = cloned
    end
    relations = Array.new
    names.each { |name| name.relations.each { |relation| relations << relation if !relations.include? relation } }
    relations.each do |relation|
      new_relation = relation.clone
      new_relation.child_node = names_to_clones[new_relation.child_node.id]
      new_relation.parent_node = names_to_clones[new_relation.parent_node.id]
      new_relation.save
    end
    return new_feature
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
# Schema version: 20110217172044
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