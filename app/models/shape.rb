class Shape < ActiveRecord::Base
  extend IsDateable
  extend IsNotable
  extend IsCitable
  
  belongs_to :feature, :foreign_key => 'fid', :primary_key => 'fid'
  
  # after_save { |record| record.feature.touch if !record.feature.nil? }
  # after_destroy { |record| record.feature.touch if !record.feature.nil? }
  
  set_primary_key "gid"
  
  def lat
    geometry.nil? ? nil : geometry.lat
  end
  
  def lng
    geometry.nil? ? nil : geometry.lng
  end
  
  def to_s
    if is_point?
      geometry.as_wkt
    else
      geometry.text_geometry_type
    end
  end
  
  def is_point?
    geometry.text_geometry_type.eql? 'POINT'
  end
  
  def geo_type
    geometry.text_geometry_type
  end
  
  #= Feature ==============================
  # A Shape belongs_to (a) Feature
  # A Feature has_many Shapes
  
  def self.find_all_by_feature(feature)
    Shape.find_all_by_fid(feature.fid, :order => "position, gid")
  end
  
  def self.find_all_by_feature_id(feature_id)
    self.find_all_by_feature(Feature.find(feature_id))
  end
  
  def after_save
    self.feature.update_shape_positions
  end
  
end

# == Schema Info
# Schema version: 20110628205752
#
# Table name: shapes
#
#  gid        :integer         not null, primary key
#  altitude   :integer
#  area       :
#  fid        :integer
#  geometry   :geometry
#  is_public  :boolean         not null, default(TRUE)
#  position   :integer         not null, default(0)
#  created_at :timestamp
#  updated_at :timestamp