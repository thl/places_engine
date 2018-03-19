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
