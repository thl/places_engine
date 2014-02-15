require_relative '../test_helper'

class FeatureNameTest < Test::Unit::TestCase
  
  fixtures :feature_names, :simple_props, :features
  
  def setup
    @one = FeatureName.find(name_to_id('one'))
    @two = FeatureName.find(name_to_id('two'))
    @three = FeatureName.find(name_to_id('three'))
  end
  
  # Check out the WritingSystem
  def test_writing_sys
    assert_equal 'tibetan', @one.writing_system.code
  end
  
  # Check out the Feature this FeatureName belongs_to
  def test_feature
    assert_equal 'F0', @one.feature.fid
  end
  
  def test_language
    assert_equal 'zho', @two.language.code
  end
  
  def test_type
    assert_equal 'official', @three.type.code
  end
  
end