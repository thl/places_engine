class CategoryFeature < ActiveRecord::Base
  attr_accessor :skip_update
  
  belongs_to :feature
  # belongs_to :category

  extend HasTimespan
  extend IsCitable
  extend IsDateable
  extend IsNotable

  after_destroy do |record|
    feature = record.feature
    CategoryFeature.delete_cumulative_information(record.category, feature.id)
    # feature.touch
  end
  
  before_save do |record|
    CategoryFeature.delete_cumulative_information(Category.find(record.category_id_was), record.feature_id_was) if record.changed? && !record.category_id_was.nil? && (record.category_id_changed? || record.feature_id_changed?)
  end
  
  after_save do |record|
    cat = record.category
    feature = record.feature
    ([cat] + cat.ancestors).each do |c|
      if (c.id==cat.id || c.cumulative?) && CumulativeCategoryFeatureAssociation.find(:first, :conditions => {:category_id => c.id, :feature_id => feature.id}).nil?
        CumulativeCategoryFeatureAssociation.create(:category_id => c.id, :feature_id => feature.id)
      end
    end
    Rails.cache.delete('CategoryFeature-max_updated_at')
    feature.update_cached_feature_relation_categories if !record.skip_update
    # feature.touch
  end
  
  def category
    Category.find(self.category_id)
  end
  
  def category_header
    return '' if !self.show_root? && !self.show_parent?
    prefix = []
    prefix << self.category.root.title if self.show_root?
    prefix << self.category.parent.title if self.show_parent?
    return "#{prefix.join(': ')} -"
  end

  def to_s
    "#{category.title}"
  end
  
  validates_presence_of :feature_id
  validates_presence_of :category_id
  
  def self.contextual_search(filter, context_id, options={})
    with_scope(:find=>{:conditions=>{:feature_id => context_id}}) do
      search(filter, options)
    end
  end
  
  def self.search(filter_value, options={})
    options[:conditions] = ['f.fid = ?', filter_value] if !filter_value.blank?
    # need to do a join here (not :include) because we're searching parents and children feature.fids
    options[:joins] = 'LEFT JOIN features f ON f.id=feature_id'
    paginate(options)
  end
  
  def self.latest_update
    Rails.cache.fetch('CategoryFeature-max_updated_at') { CategoryFeature.maximum(:updated_at) }
  end
  
  private
  
  def self.delete_cumulative_information(category, feature_id)
    while !category.nil? && CumulativeCategoryFeatureAssociation.count(:conditions => {:category_id => category.children.collect(&:id), :feature_id => feature_id})==0
      CumulativeCategoryFeatureAssociation.delete_all(:category_id => category.id.to_i, :feature_id => feature_id)
      CachedCategoryCount.updated_count(category.id.to_i, true)
      category = category.parent
    end
  end
end

# == Schema Info
# Schema version: 20110629163847
#
# Table name: category_features
#
#  id             :integer         not null, primary key
#  category_id    :integer         not null
#  feature_id     :integer         not null
#  perspective_id :integer
#  numeric_value  :integer
#  position       :integer         not null, default(0)
#  show_parent    :boolean         not null
#  show_root      :boolean         not null, default(TRUE)
#  string_value   :string(255)
#  type           :string(255)
#  created_at     :timestamp
#  updated_at     :timestamp