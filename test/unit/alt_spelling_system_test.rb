require_relative '../test_helper'

class AltSpellingSystemTest < Test::Unit::TestCase
  
  fixtures :simple_props
  
  def test_invalid_create
    assert_equal false, AltSpellingSystem.create.valid?
  end
  
  def test_valid_create
    assert_equal true, AltSpellingSystem.create(:code=>'B660').valid?
  end
  
  def test_duplicate_codes_will_not_save
    count = AltSpellingSystem.find(:all).size
    AltSpellingSystem.create(:code=>'B660')
    # this next one should not save
    AltSpellingSystem.create(:code=>'B660')
    assert_equal count + 1, AltSpellingSystem.find(:all).size
  end
end