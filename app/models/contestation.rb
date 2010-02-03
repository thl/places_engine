# == Schema Information
# Schema version: 20091102185045
#
# Table name: contestations
#
#  id               :integer         not null, primary key
#  feature_id       :integer         not null
#  contested        :boolean         default(TRUE), not null
#  administrator_id :integer
#  claimant_id      :integer
#  created_at       :timestamp
#  updated_at       :timestamp
#

class Contestation < ActiveRecord::Base
  belongs_to :administrator, :class_name => 'Feature'
  belongs_to :claimant, :class_name => 'Feature'
  belongs_to :feature
end
