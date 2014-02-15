require_relative '../test_helper'

class FeatureNameRelationTest < Test::Unit::TestCase
  
  fixtures :feature_name_relations, :feature_names
  
  def setup
    @one_to_nine = FeatureNameRelation.find(name_to_id('one_to_nine'))
  end
  
  # Get the feature_name.name and related_feature.name
  def test_access_feature_name
    assert_equal 'krung go', @one_to_nine.child_node.name
    assert_equal 'ཀྲུང་གོ', @one_to_nine.parent_node.name
  end
  
end