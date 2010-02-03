require File.dirname(__FILE__) + '/../test_helper'

require 'features_controller'

# Raise errors beyond the default web-based presentation
class FeaturesController; def rescue_action(e) raise e end; end

class FeaturesControllerTest < ActionController::TestCase
  
  def setup
    @controller = FeaturesController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
  end
  
  # let's test our main index page
  def test_index
    get :index
    assert_nil assigns[:context_feature]
    assert_response :success
  end
  
end
