require 'test_helper'

class PrivacyPoliciesControllerTest < ActionController::TestCase
  setup do
    @privacy_policy = privacy_policies(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:privacy_policies)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create privacy_policy" do
    assert_difference('PrivacyPolicy.count') do
      post :create, privacy_policy: {  }
    end

    assert_redirected_to privacy_policy_path(assigns(:privacy_policy))
  end

  test "should show privacy_policy" do
    get :show, id: @privacy_policy
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @privacy_policy
    assert_response :success
  end

  test "should update privacy_policy" do
    put :update, id: @privacy_policy, privacy_policy: {  }
    assert_redirected_to privacy_policy_path(assigns(:privacy_policy))
  end

  test "should destroy privacy_policy" do
    assert_difference('PrivacyPolicy.count', -1) do
      delete :destroy, id: @privacy_policy
    end

    assert_redirected_to privacy_policies_path
  end
end
