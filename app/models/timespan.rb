# == Schema Information
# Schema version: 20091102185045
#
# Table name: timespans
#
#  id              :integer         not null, primary key
#  start_date      :date
#  end_date        :date
#  start_date_fuzz :integer
#  end_date_fuzz   :integer
#  is_current      :integer
#  dateable_id     :integer
#  dateable_type   :string(255)
#  created_at      :timestamp
#  updated_at      :timestamp
#

class Timespan < ActiveRecord::Base
  
  belongs_to :dateable, :polymorphic=>true
  
  def to_s
    id.to_s
  end
  
  def self.search(filter_value, options={})
    # Empty constraints here... ? what conditions for timespan search?
    options[:conditions] = build_like_conditions(
      %W(),
      filter_value
    )
    paginate(options)
  end
  
end
