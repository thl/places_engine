# == Schema Information
# Schema version: 20091102185045
#
# Table name: feature_object_types
#
#  id             :integer         not null, primary key
#  feature_id     :integer         not null
#  object_type_id :integer         not null
#  perspective_id :integer
#  created_at     :timestamp
#  updated_at     :timestamp
#  position       :integer         :default => 0
#

class FeatureObjectType < ActiveRecord::Base
  
  #
  #
  # Associations
  #
  #
  belongs_to :feature
  belongs_to :object_type, :class_name => 'Category'
  belongs_to :perspective
  
  extend HasTimespan
  extend IsCitable
  
  def to_s
    "#{object_type.title}"
  end
  
  validates_presence_of :feature_id
  validates_presence_of :object_type_id
  
  def self.contextual_search(filter, context_id, options={})
    with_scope(:find=>{:conditions=>{:feature_id => context_id}}) do
      search(filter, options)
    end
  end
  
  def self.search(filter_value, options={})
    options[:conditions] = ['features.fid = ?', filter_value] if !filter_value.blank?
    # need to do a join here (not :include) because we're searching parents and children feature.fids
    options[:joins] = 'LEFT JOIN features f ON f.id=feature_id'
    paginate(options)
  end
  
  def after_destroy
    FeatureObjectType.delete_cumulative_information(self.object_type, self.feature_id)
  end
  
  def before_save
    FeatureObjectType.delete_cumulative_information(Category.find(self.object_type_id_was), self.feature_id_was) if self.changed? && !self.object_type_id_was.nil? && (self.object_type_id_changed? || self.feature_id_changed?)
  end
  
  def after_save
    category = self.object_type
    ([category] + category.ancestors).each do |c|
      if (c.id==category.id || c.cumulative?) && CumulativeCategoryFeatureAssociation.find(:first, :conditions => {:category_id => c.id, :feature_id => self.feature_id}).nil?
        CumulativeCategoryFeatureAssociation.create(:category => c, :feature_id => self.feature_id)
      end
    end
    FeatureObjectType.update_latest
    self.feature.update_object_type_positions
  end
  
  def self.latest_update
    return @@max_updated_at if defined? @@max_updated_at
    @@max_updated_at = self.update_latest
  end
  
  private
  
  def self.update_latest
    @@max_updated_at = self.maximum(:updated_at)
  end
  
  def self.delete_cumulative_information(category, feature_id)
    while !category.nil? && CumulativeCategoryFeatureAssociation.count(:conditions => {:category_id => category.children.collect(&:id), :feature_id => feature_id})==0
      CumulativeCategoryFeatureAssociation.delete_all(:category_id => category.id.to_i, :feature_id => feature_id)
      CachedCategoryCount.updated_count(category.id.to_i, true)
      category = category.parent
    end
  end
end
