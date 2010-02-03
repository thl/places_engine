# == Schema Information
# Schema version: 20091102185045
#
# Table name: feature_geo_codes
#
#  id               :integer         not null, primary key
#  feature_id       :integer
#  geo_code_type_id :integer
#  timespan_id      :integer
#  geo_code_value   :string(255)
#  notes            :text
#  created_at       :timestamp
#  updated_at       :timestamp
#

class FeatureGeoCode < ActiveRecord::Base
  
  belongs_to :feature
  belongs_to :geo_code_type
  belongs_to :info_source
  
  extend IsCitable
  extend HasTimespan
  
  def self.search(filter_value, options={})
    options[:conditions] = build_like_conditions(
      # because a GeoCodeType is actualy a SimpleProp, this LIKE query should be checking simple_props (not geo_code_types)
      %W(feature_geo_codes.notes simple_props.code simple_props.name simple_props.notes),
      filter_value
    )
    options[:include]=[:feature, :geo_code_type]
    paginate(options)
  end
  
  def to_s
    [geo_code_type.to_s, id.to_s].detect {|i| ! i.blank? }
  end
  
end
