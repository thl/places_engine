class Citation < ActiveRecord::Base
  
  attr_accessor :marked_for_deletion
  
  #
  #
  # Associations
  #
  #
  belongs_to :info_source
  belongs_to :citable, :polymorphic=>true
  
  #
  #
  # Validation
  #
  #
  
  def to_s
    citable.to_s
  end
  
  def self.search(filter_value, options={})
    options[:conditions] = build_like_conditions(
      %W(citations.notes info_sources.code info_sources.title info_sources.agent),
      filter_value
    )
    options[:include] = [:info_source]
    paginate(options)
  end
  
end


# == Schema Info
# Schema version: 20100428184445
#
# Table name: citations
#
#  id             :integer         not null, primary key
#  citable_id     :integer
#  info_source_id :integer
#  citable_type   :string(255)
#  notes          :text
#  pages          :string(255)
#  created_at     :timestamp
#  updated_at     :timestamp