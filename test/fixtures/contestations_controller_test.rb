require 'test_helper'

class ContestationsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:contestations)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_contestation
    assert_difference('Contestation.count') do
      post :create, :contestation => { }
    end

    assert_redirected_to contestation_path(assigns(:contestation))
  end

  def test_should_show_contestation
    get :show, :id => contestations(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => contestations(:one).id
    assert_response :success
  end

  def test_should_update_contestation
    put :update, :id => contestations(:one).id, :contestation => { }
    assert_redirected_to contestation_path(assigns(:contestation))
  end

  def test_should_destroy_contestation
    assert_difference('Contestation.count', -1) do
      delete :destroy, :id => contestations(:one).id
    end

    assert_redirected_to contestations_path
  end
end
