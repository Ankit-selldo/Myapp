require "test_helper"

class SubProductsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get sub_products_new_url
    assert_response :success
  end

  test "should get create" do
    get sub_products_create_url
    assert_response :success
  end

  test "should get edit" do
    get sub_products_edit_url
    assert_response :success
  end

  test "should get update" do
    get sub_products_update_url
    assert_response :success
  end

  test "should get destroy" do
    get sub_products_destroy_url
    assert_response :success
  end
end
