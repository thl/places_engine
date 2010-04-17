class CategoryFeature < ActiveRecord::Base
  belongs_to :feature
  belongs_to :category

  extend HasTimespan
  extend IsCitable
  extend IsDateable
  extend IsNotable

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

  def after_destroy
    FeatureObjectType.delete_cumulative_information(self.category, self.feature_id)
  end
  
  def before_save
    FeatureObjectType.delete_cumulative_information(Category.find(self.category_id_was), self.feature_id_was) if self.changed? && !self.category_id_was.nil? && (self.category_id_changed? || self.feature_id_changed?)
  end
  
  def after_save
    cat = self.category
    ([cat] + cat.ancestors).each do |c|
      if (c.id==cat.id || c.cumulative?) && CumulativeCategoryFeatureAssociation.find(:first, :conditions => {:category_id => c.id, :feature_id => self.feature_id}).nil?
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