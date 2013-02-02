class CachedFeatureName < ActiveRecord::Base
  attr_accessible :view_id, :feature_name_id
  validates_presence_of :feature_id, :view_id
  
  belongs_to :feature
  belongs_to :view
  belongs_to :feature_name
end

# == Schema Info
# Schema version: 20110923232332
#
# Table name: cached_feature_names
#
#  id              :integer         not null, primary key
#  feature_id      :integer         not null
#  feature_name_id :integer
#  view_id         :integer         not null
#  created_at      :timestamp
#  updated_at      :timestamp