class CategoryFeature < ActiveRecord::Base
  attr_accessor :skip_update
  
  belongs_to :feature
  belongs_to :perspective, optional: true
  has_many :imports, :as => 'item', :dependent => :destroy
  # belongs_to :category

  extend KmapsEngine::HasTimespan
  include KmapsEngine::IsCitable
  extend IsDateable
  include KmapsEngine::IsNotable

  validates_presence_of :feature_id
  validates_presence_of :category_id
  validate :correct_master_parent_selection

  def correct_master_parent_selection
    category = SubjectsIntegration::Feature.find(self.category_id)
    # selected show parent and Category is top level
    if (self.show_parent && category.ancestors.count <= 1)
      errors.add(:base, 'Show immediate parent is not valid for root nodes.')
    end
    # selected show root and Category is top level
    if (self.show_root && category.ancestors.count <= 1)
      errors.add(:base, 'Show master subject is not valid for root nodes.')
    end
    # selected show parent and root for Category in second level
    if (self.show_root && self.show_parent && category.ancestors.count == 2 )
      errors.add(:base, 'Can not select both show immediate parent and show master subject for category in second level, choose one.')
    end
  end

  after_destroy do |record|
    feature = record.feature
    CategoryFeature.delete_cumulative_information(record.category, feature.id)
    # feature.touch
  end
  
  before_save do |record|
    CategoryFeature.delete_cumulative_information(SubjectsIntegration::Feature.find(record.category_id_was), record.feature_id_was) if record.changed? && !record.category_id_was.nil? && (record.category_id_changed? || record.feature_id_changed?)
  end
  
  after_save do |record|
    cat = record.category
    feature = record.feature
    ([cat] + cat.ancestors).each do |c|
      # Got rid of conditions while I figure out how to deal with this c.id==cat.id || c.cumulative?
      if CumulativeCategoryFeatureAssociation.find_by(category_id: c.id, feature_id: feature.id).nil?
        CumulativeCategoryFeatureAssociation.create(:category_id => c.id, :feature_id => feature.id)
      end
    end
    Rails.cache.delete('CategoryFeature-max_updated_at')
    Rails.cache.delete('category_feature/get_json_data')
    feature.update_cached_feature_relation_categories if !record.skip_update
    # feature.touch
  end
    
  def category_stack
    stack = []
    stack << self.label if !label.blank? && self.prefix_label
    stack << self.category.sub_root.header if self.show_root?
    stack << self.category.parent.header if self.show_parent?
    stack << self.category.header
    stack[stack.size-1] = stack[stack.size-1] + " #{self.label}" if !label.blank? && !self.prefix_label
    stack
  end
  
  def stacked_category
    return category_stack.join(' > ')
  end
  
  def category
    SubjectsIntegration::Feature.find(self.category_id)
  end
  
  def to_s
    "#{category.header}"
  end
  
  def display_string
    values = []
    values << self.string_value if !self.string_value.blank?
    values << self.numeric_value if !self.numeric_value.nil?
    stack = self.category_stack
    display = stack.join(' > ')
    display << ": #{values.join(', ')}" if !values.empty?
    display
  end
  
  def self.contextual_search(filter, context_id)
    self.search(filter).where(:feature_id => context_id)
  end
  
  def self.search(filter_value)
    # need to do a join here (not :include) because we're searching parents and children feature.fids
    search_results = self.joins('LEFT JOIN features f ON f.id=feature_id')
    filter_value.blank? ? search_results : search_results.where(['f.fid = ?', filter_value])
  end
  
  def self.latest_update
    Rails.cache.fetch('CategoryFeature-max_updated_at', :expires_in => 1.day) { CategoryFeature.maximum(:updated_at) }
  end
  
  def self.get_json_data
    Rails.cache.fetch('category_feature/get_json_data', :expires_in => 1.day) { CategoryFeature.select('DISTINCT category_id').where(:type => nil).collect{|c| {:value => c.category_id, :label => c.to_s}}.sort_by{|a| a[:label].downcase.strip}.to_json.html_safe }
  end
  
  private
  
  def self.delete_cumulative_information(category, feature_id)
    while !category.nil? && CumulativeCategoryFeatureAssociation.where(:category_id => category.children.collect(&:id), :feature_id => feature_id).count==0
      CumulativeCategoryFeatureAssociation.where(:category_id => category.id.to_i, :feature_id => feature_id).delete_all
      CachedCategoryCount.updated_count(category.id.to_i, true)
      category = category.parent
    end
  end
end
# == Schema Information
#
# Table name: category_features
#
#  id             :integer          not null, primary key
#  feature_id     :integer          not null
#  category_id    :integer          not null
#  perspective_id :integer
#  created_at     :datetime
#  updated_at     :datetime
#  position       :integer          default(0), not null
#  type           :string(255)
#  string_value   :string(255)
#  numeric_value  :integer
#  show_parent    :boolean          default(FALSE), not null
#  show_root      :boolean          default(TRUE), not null
#  label          :string(255)
#  prefix_label   :boolean          default(TRUE), not null
#

#  updated_at     :timestamp
