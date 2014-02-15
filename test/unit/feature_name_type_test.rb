require_relative '../test_helper'

class FeatureNameTypeTest < Test::Unit::TestCase
  
  fixtures :simple_props, :feature_names
  
  def setup
    @official = FeatureNameType.find(name_to_id('fnt_official'))
  end
  
  def test_feature_name_count
    assert_equal 15, @official.feature_names.size
  end
  
  def test_first_feature_name
    fn_name = @official.feature_names.find( name_to_id('one') ).name
    assert_equal 'ཀྲུང་གོ', fn_name
  end
  
end