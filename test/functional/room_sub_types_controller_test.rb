require 'test_helper'

class RoomSubTypesControllerTest < ActionController::TestCase
  setup do
    @room_sub_type = room_sub_types(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:room_sub_types)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create room_sub_type" do
    assert_difference('RoomSubType.count') do
      post :create, room_sub_type: { name: @room_sub_type.name, room_type_id: @room_sub_type.room_type_id }
    end

    assert_redirected_to room_sub_type_path(assigns(:room_sub_type))
  end

  test "should show room_sub_type" do
    get :show, id: @room_sub_type
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @room_sub_type
    assert_response :success
  end

  test "should update room_sub_type" do
    put :update, id: @room_sub_type, room_sub_type: { name: @room_sub_type.name, room_type_id: @room_sub_type.room_type_id }
    assert_redirected_to room_sub_type_path(assigns(:room_sub_type))
  end

  test "should destroy room_sub_type" do
    assert_difference('RoomSubType.count', -1) do
      delete :destroy, id: @room_sub_type
    end

    assert_redirected_to room_sub_types_path
  end
end
