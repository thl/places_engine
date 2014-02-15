require_relative '../../test_helper'
require 'admin/features_controller'

# Re-raise errors caught by the controller.
class Admin::FeaturesController; def rescue_action(e) raise e end; end

class Admin::FeaturesControllerTest < Test::Unit::TestCase
  fixtures :features

  def setup
    @controller = Admin::FeaturesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_create_new_feature
    login_as :quentin
    get :new
    assert_response :success
    assert_template 'admin/features/new'
    assert_not_nil assigns['object']
    object = assigns['object']
  end
end
