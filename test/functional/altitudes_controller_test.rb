require 'test_helper'

class AltitudesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:altitudes)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create altitude" do
    assert_difference('Altitude.count') do
      post :create, :altitude => { }
    end

    assert_redirected_to altitude_path(assigns(:altitude))
  end

  test "should show altitude" do
    get :show, :id => altitudes(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => altitudes(:one).to_param
    assert_response :success
  end

  test "should update altitude" do
    put :update, :id => altitudes(:one).to_param, :altitude => { }
    assert_redirected_to altitude_path(assigns(:altitude))
  end

  test "should destroy altitude" do
    assert_difference('Altitude.count', -1) do
      delete :destroy, :id => altitudes(:one).to_param
    end

    assert_redirected_to altitudes_path
  end
end
