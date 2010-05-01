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


# == Schema Info
# Schema version: 20100428184445
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