# == Schema Information
# Schema version: 20091102185045
#
# Table name: shapes
#
#  gid      :integer         not null, primary key
#  geometry :geometry
#  fid      :integer
#  position :integer         :default => 0
#

class Shape < ActiveRecord::Base
  belongs_to :feature, :foreign_key => 'fid'
  
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
