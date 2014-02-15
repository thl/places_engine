require_relative '../test_helper'

class FeatureRelationTest < Test::Unit::TestCase
  
  fixtures :feature_relations, :features, :info_sources, :citations#, :perspectives
  
  def setup
    @tibet_partof_china = FeatureRelation.find(name_to_id('tibet_partof_china'))
    @lhasa_partof_tibet = FeatureRelation.find(name_to_id('lhasa_partof_tibet'))
  end
  
  def test_f2_relates_to_f1
    # The source is Tibet
    assert_equal 'F1', @tibet_partof_china.child_node.fid
    # The target is China
    assert_equal 'F0', @tibet_partof_china.parent_node.fid
  end
  
  # def test_perspective_name
  #   assert_equal 'Contemporary Administrative Hierarchy', @tibet_partof_china.perspective.name
  # end
  
  # Check out the first Citations InfoSource
  def test_info_source
    assert_equal 'info_source_2', @lhasa_partof_tibet.citations.first.info_source.code
  end
  
end