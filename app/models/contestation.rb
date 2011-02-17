class Contestation < ActiveRecord::Base
  belongs_to :administrator, :class_name => 'Feature'
  belongs_to :claimant, :class_name => 'Feature'
  belongs_to :feature
end

# == Schema Info
# Schema version: 20110217172044
#
# Table name: contestations
#
#  id               :integer         not null, primary key
#  administrator_id :integer
#  claimant_id      :integer
#  feature_id       :integer         not null
#  contested        :boolean         not null, default(TRUE)
#  created_at       :timestamp
#  updated_at       :timestamp