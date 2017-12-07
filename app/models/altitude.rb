class Altitude < ActiveRecord::Base
  include KmapsEngine::IsCitable
  extend IsDateable
  include KmapsEngine::IsNotable
  
  belongs_to :feature
  belongs_to :unit
  has_many :imports, :as => 'item', :dependent => :destroy
  
  def unit
    self.unit_id.nil? ? nil : Unit.find(self.unit_id)
  end

  def unit=(obj)
    self.unit_id = obj.id
  end
  
  
  def to_s
    s = !average.nil? ? average.to_s : ''
    if !minimum.nil? || !maximum.nil?
      s << ' ('
      if !minimum.nil?
        s << minimum.to_s
        s << " - #{maximum}" if !maximum.nil?
      else 
        s << maximum.to_s
      end
      s << ')'
    end
    s << " #{unit.title}"
    s
  end
  
end
# == Schema Information
#
# Table name: altitudes
#
#  id         :integer          not null, primary key
#  feature_id :integer          not null
#  maximum    :integer
#  minimum    :integer
#  average    :integer
#  unit_id    :integer          not null
#  created_at :datetime
#  updated_at :datetime
#  estimate   :string(255)
#

#  updated_at :timestamp
