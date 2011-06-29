class Citation < ActiveRecord::Base
  
  attr_accessor :marked_for_deletion
  
  #
  #
  # Associations
  #
  #
  belongs_to :info_source, :class_name => 'Document'
  belongs_to :citable, :polymorphic=>true
  has_many :pages
  
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
      %W(citations.notes),
      filter_value
    )
    paginate(options)
  end
  
end

# == Schema Info
# Schema version: 20110629163847
#
# Table name: citations
#
#  id             :integer         not null, primary key
#  citable_id     :integer
#  info_source_id :integer
#  citable_type   :string(255)
#  notes          :text
#  created_at     :timestamp
#  updated_at     :timestamp