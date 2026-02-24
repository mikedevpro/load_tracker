require "test_helper"

class DriversControllerTest < ActionDispatch::IntegrationTest
  test "destroy nullifies load driver and returns 204" do
    driver = drivers(:one)
    load = loads(:one)

    assert_equal driver.id, load.driver_id

    assert_difference("Driver.count", -1) do
      delete driver_url(driver)
    end

    assert_response :no_content
    assert_nil load.reload.driver_id
  end
end
