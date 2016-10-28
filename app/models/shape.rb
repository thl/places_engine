class Shape < ActiveRecord::Base
  extend IsDateable
  include KmapsEngine::IsNotable
  include KmapsEngine::IsCitable
  
  attr_accessible :altitude, :geometry, :fid
  belongs_to :feature, :foreign_key => 'fid', :primary_key => 'fid'
  
  # after_save { |record| record.feature.touch if !record.feature.nil? }
  # after_destroy { |record| record.feature.touch if !record.feature.nil? }
  
  self.primary_key = 'gid'
  
  def lat
    # if done with rgeo:
    # self.geometry.nil? ? nil : self.geometry.y
    # If done directly from db:
    self.geometry.nil? ? nil : Shape.select('ST_Y(geometry) as st_y').find(self.id).st_y
  end
  
  def lng
    # if done with rgeo:
    # self.geometry.nil? ? nil : self.geometry.x
    # If done directly from db:
    self.geometry.nil? ? nil : Shape.select('ST_X(geometry) as st_x').find(self.id).st_x
  end
  
  def to_s
    if self.is_point?
      self.as_text
    else
      self.geo_type
    end
  end
  
  def is_point?
    # if done with rgeo:
    # self.geo_type == RGeo::Feature::Point # if done through db: 'ST_Point'
    # if done through db: 'ST_Point'
    self.geo_type == 'ST_Point'
  end
  
  def geo_type
    # if done with rgeo:
    # self.geometry.geometry_type
    # If done directly from db:
    Shape.select('ST_GeometryType(geometry) as geometry_type').find(self.id).geometry_type
  end
  
  def as_text
    # if done with rgeo:
    # self.geometry.as_text
    # If done directly from db:
    Shape.select('ST_AsText(geometry) as astext').find(self.id).astext
  end
  
  def as_ewkt
    Shape.select('ST_AsEWKT(geometry) as astext').find(self.id).astext
  end
  
  #= Feature ==============================
  # A Shape belongs_to (a) Feature
  # A Feature has_many Shapes
  
  def self.find_all_by_feature(feature)
    Shape.where(fid: feature.fid).order('position, gid')
  end
  
  def self.find_all_by_feature_id(feature_id)
    self.where(feature_id: Feature.find(feature_id).id)
  end
  
  def after_save
    self.feature.update_shape_positions
  end
  
end
# == Schema Information
#
# Table name: shapes
#
#  gid        :integer          not null, primary key
#  geometry   :geometry
#  fid        :integer
#  position   :integer          default(0), not null
#  area       :float
#  altitude   :integer
#  is_public  :boolean          default(TRUE), not null
#  created_at :datetime
#  updated_at :datetime
#

#  updated_at :timestamp
