require 'test_helper'

class CommissionRatesControllerTest < ActionController::TestCase
  setup do
    @commission_rate = commission_rates(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:commission_rates)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create commission_rate" do
    assert_difference('CommissionRate.count') do
      post :create, commission_rate: { amount: @commission_rate.amount }
    end

    assert_redirected_to commission_rate_path(assigns(:commission_rate))
  end

  test "should show commission_rate" do
    get :show, id: @commission_rate
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @commission_rate
    assert_response :success
  end

  test "should update commission_rate" do
    put :update, id: @commission_rate, commission_rate: { amount: @commission_rate.amount }
    assert_redirected_to commission_rate_path(assigns(:commission_rate))
  end

  test "should destroy commission_rate" do
    assert_difference('CommissionRate.count', -1) do
      delete :destroy, id: @commission_rate
    end

    assert_redirected_to commission_rates_path
  end
end
