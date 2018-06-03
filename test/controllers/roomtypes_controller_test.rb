require 'test_helper'

class RoomtypesControllerTest < ActionController::TestCase
  setup do
    @roomtype = roomtypes(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:roomtypes)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create roomtype" do
    assert_difference('Roomtype.count') do
      post :create, roomtype: { description: @roomtype.description, name: @roomtype.name }
    end

    assert_redirected_to roomtype_path(assigns(:roomtype))
  end

  test "should show roomtype" do
    get :show, id: @roomtype
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @roomtype
    assert_response :success
  end

  test "should update roomtype" do
    patch :update, id: @roomtype, roomtype: { description: @roomtype.description, name: @roomtype.name }
    assert_redirected_to roomtype_path(assigns(:roomtype))
  end

  test "should destroy roomtype" do
    assert_difference('Roomtype.count', -1) do
      delete :destroy, id: @roomtype
    end

    assert_redirected_to roomtypes_path
  end
end
