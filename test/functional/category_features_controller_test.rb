require 'test_helper'

class CategoryFeaturesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:category_features)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create category_feature" do
    assert_difference('CategoryFeature.count') do
      post :create, :category_feature => { }
    end

    assert_redirected_to category_feature_path(assigns(:category_feature))
  end

  test "should show category_feature" do
    get :show, :id => category_features(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => category_features(:one).to_param
    assert_response :success
  end

  test "should update category_feature" do
    put :update, :id => category_features(:one).to_param, :category_feature => { }
    assert_redirected_to category_feature_path(assigns(:category_feature))
  end

  test "should destroy category_feature" do
    assert_difference('CategoryFeature.count', -1) do
      delete :destroy, :id => category_features(:one).to_param
    end

    assert_redirected_to category_features_path
  end
end
