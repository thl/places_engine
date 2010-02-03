# == Schema Information
# Schema version: 20091102185045
#
# Table name: citations
#
#  id             :integer         not null, primary key
#  info_source_id :integer
#  citable_type   :string(255)
#  citable_id     :integer
#  pages          :string(255)
#  notes          :text
#  created_at     :timestamp
#  updated_at     :timestamp
#

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
