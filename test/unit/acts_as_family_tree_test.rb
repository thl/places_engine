require_relative '../test_helper'

class FeatureTest < Test::Unit::TestCase
  
  # We need to load all of the related data
  fixtures :features, :feature_relations
  
  def find_node(number)
    Feature.find(name_to_id("node_#{number}"))
  end
  
  #
  # Test the recursive method calls for ancestors and descendants
  #
  def test_recursive_methods
    assert_equal 0, find_node(1).ancestors_r.size
    assert_equal 8, find_node(1).descendants_r.size
    assert_equal 4, find_node('1_1_2_1_1').ancestors_r.size
  end
  
  #
  # In order for the ancestor_ids method to work (finds relations based on a path made from ancestor/descendant ids),
  # the paths must be built
  #
  def test_node_1_has_0_ancestors_after_building_ancestors_ids_attribute
    id=1
    assert_equal 0, find_node(id).ancestors.size
    assert find_node(id).update_ancestor_ids
    assert_equal 0, find_node(id).ancestors.size
  end
  
  def test_node_1_has_7_descendants_after_building_ancestor_ids_attribute
    id=1
    assert_equal 0, find_node(id).descendants.size
    find_node(id).update_descendant_ancestor_ids
    assert_equal 8, find_node(id).descendants.size
  end
  
  def test_node_1_1_2_1_1_has_4_ancestors_after_building_ancestor_ids_attribute
    id='1_1_2_1_1'
    assert_equal 0, find_node(id).ancestors.size
    find_node(id).update_ancestor_ids
    assert_equal 4, find_node(id).ancestors.size
  end
  
  def test_node_1_1_2_1_has_3_ancestors_after_building_ancestor_ids_attribute
    id='1_1_2_1'
    assert_equal 0, find_node(id).ancestors.size
    find_node(id).update_ancestor_ids
    assert_equal 3, find_node(id).ancestors.size
  end
  
end