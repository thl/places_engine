class Altitude < ActiveRecord::Base
  extend IsCitable
  extend IsDateable
  extend IsNotable
  
  belongs_to :feature
  belongs_to :unit
  
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

# == Schema Info
# Schema version: 20100623234636
#
# Table name: altitudes
#
#  id         :integer         not null, primary key
#  feature_id :integer         not null
#  unit_id    :integer         not null
#  average    :integer
#  maximum    :integer
#  minimum    :integer
#  created_at :timestamp
#  updated_at :timestamp