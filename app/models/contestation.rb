class Contestation < ActiveRecord::Base
  attr_accessible :administrator, :claimant, :contested
  belongs_to :administrator, :class_name => 'Feature'
  belongs_to :claimant, :class_name => 'Feature'
  belongs_to :feature
  has_many :imports, :as => 'item', :dependent => :destroy
end
# == Schema Information
#
# Table name: contestations
#
#  id               :integer          not null, primary key
#  feature_id       :integer          not null
#  contested        :boolean          default(TRUE), not null
#  administrator_id :integer
#  claimant_id      :integer
#  created_at       :datetime
#  updated_at       :datetime
#

#  updated_at       :timestamp
