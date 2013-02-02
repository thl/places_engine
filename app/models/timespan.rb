class Timespan < ActiveRecord::Base
  attr_accessible :is_current
  belongs_to :dateable, :polymorphic=>true
  
  def to_s
    id.to_s
  end
  
  def self.search(filter_value)
    # Empty constraints here... ? what conditions for timespan search?
    self.where(build_like_conditions(%W(), filter_value))
  end
end

# == Schema Info
# Schema version: 20110923232332
#
# Table name: timespans
#
#  id              :integer         not null, primary key
#  dateable_id     :integer
#  dateable_type   :string(255)
#  end_date        :date
#  end_date_fuzz   :integer
#  is_current      :integer
#  start_date      :date
#  start_date_fuzz :integer
#  created_at      :timestamp
#  updated_at      :timestamp