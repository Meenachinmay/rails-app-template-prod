require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get root_url
    assert_response :success
    assert_select ".r-nav"
    assert_select ".r-post"
    assert_select ".r-logo-mark"
    assert_match(/Bookkit/, response.body)
    assert_match(/r\/bookkit/, response.body)
    assert_match(/Tailwind/, response.body)
  end

  test "health check is ok" do
    get rails_health_check_url
    assert_response :success
  end
end
