require 'test_helper'

class RateCategoriesControllerTest < ActionController::TestCase
  setup do
    @rate_category = rate_categories(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:rate_categories)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create rate_category" do
    assert_difference('RateCategory.count') do
      post :create, rate_category: { name: @rate_category.name }
    end

    assert_redirected_to rate_category_path(assigns(:rate_category))
  end

  test "should show rate_category" do
    get :show, id: @rate_category
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @rate_category
    assert_response :success
  end

  test "should update rate_category" do
    put :update, id: @rate_category, rate_category: { name: @rate_category.name }
    assert_redirected_to rate_category_path(assigns(:rate_category))
  end

  test "should destroy rate_category" do
    assert_difference('RateCategory.count', -1) do
      delete :destroy, id: @rate_category
    end

    assert_redirected_to rate_categories_path
  end
end
