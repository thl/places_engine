require File.dirname(__FILE__) + '/../../test_helper'

class FeaturesHelperTest < Test::Unit::TestCase

  include FeaturesHelper
  
  def setup
    @tree_builder = new_tree_builder
  end

  def test_tree_builder_correctly_built
    assert_not_nil(@tree_builder)
    assert_kind_of(ContextualTreeBuilder, @tree_builder)
  end
  
  def test_build_tree_with_nil_context_feature
    # puts @tree_builder.build(nil)
  end
  
end
