require File.dirname(__FILE__) + '/../test_helper'

class ActiveRecordExtTest < Test::Unit::TestCase
  
  def setup
    @fields=%W(features.description feature_names.name)
  end
  
  def test_build_like_conditions_returns_nil_when_filter_is_nil_or_empty
    return_all = true
    conds = ActiveRecord::Base.build_like_conditions(@fields, '', return_all)
    assert_nil conds
  end
  
  def test_build_like_conditions_returns_array_when_filter_value_is_not_nil_or_blank
    return_all = true
    conds = ActiveRecord::Base.build_like_conditions(@fields, 'test', return_all)
    assert_kind_of(Array, conds)
    assert_equal 'features.description ILIKE ? OR feature_names.name ILIKE ?', conds[0]
    assert_equal ["%test%", "%test%", "%test%"], conds.slice(1, @fields.size)
  end
end