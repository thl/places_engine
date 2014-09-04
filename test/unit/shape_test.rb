require_relative '../test_helper'

class ShapeTest < ActiveSupport::TestCase
  fixtures :shapes, :features
  
  def setup
    @shape1 = shapes(:point_one)
  end
  
  def test_shape_feature_relationship
    assert_equal @shape1.feature, features(:china)
    assert_equal @shape1, features(:china).shapes.first
    
    assert_equal 0, features(:lhasa).shapes.size
    assert_equal 1, features(:tibet).shapes.size
    assert_equal 2, features(:china).shapes.size
  end
  
  def test_shape_finder_methods
    assert_equal 1, Shape.find_all_by_feature(features(:tibet)).size
    assert_equal 1, Shape.find_all_by_feature_id(features(:tibet).id).size
    assert_equal Shape.find_all_by_feature(features(:tibet)), Shape.find_all_by_feature_id(features(:tibet).id)
    assert_equal features(:tibet).shapes, Shape.find_all_by_feature(features(:tibet))
  end
  
  def test_geometry_access
    assert_equal "SRID=4326;POINT(91.1589999999938 29.695999999506)", @shape1.as_ewkt
    assert_equal "POINT(91.1589999999938 29.695999999506)", @shape1.as_text
    assert_equal "POINT", @shape1.geo_type.to_s
  end
  
  def test_edit_geometry
    shape2 = shapes(:point_two)
    geom1 = @shape1.geometry
    geom2 = shape2.geometry
    assert !(geom1.lat == geom2.lat)
    
    geom2.lat = geom1.lat
    assert (geom1.lat == geom2.lat)
    geom2.lng = geom1.lng
    assert (geom1.lng == geom2.lng)
    shape2.geometry = geom2
    shape2.save
    shape2.reload
    assert (shape2.lat == geom2.lat)
    assert (shape2.lat == @shape1.lat)
    
    assert_equal @shape1.as_ewkt, shape2.as_ewkt
  end
  
  def test_to_s
    assert_equal @shape1.as_text, @shape1.to_s
    assert_equal shapes(:line_one).geo_type.to_s, shapes(:line_one).to_s
  end
  
  def test_is_point?
    assert @shape1.is_point?
    assert !shapes(:line_one).is_point?
  end
end
