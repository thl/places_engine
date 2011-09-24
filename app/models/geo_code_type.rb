class GeoCodeType < SimpleProp
  has_many :feature_geo_codes
  has_many :features, :through => :feature_geo_codes
end

# == Schema Info
# Schema version: 20110923232332
#
# Table name: simple_props
#
#  id          :integer         not null, primary key
#  code        :string(255)
#  description :text
#  name        :string(255)
#  notes       :text
#  type        :string(255)
#  created_at  :timestamp
#  updated_at  :timestamp