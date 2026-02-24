require "test_helper"

class CustomersControllerTest < ActionDispatch::IntegrationTest
  test "destroy returns 422 when customer has loads" do
    customer = customers(:one)

    assert_no_difference("Customer.count") do
      delete customer_url(customer)
    end

    assert_response :unprocessable_entity
    assert_includes response.parsed_body["errors"].join(" "), "Cannot delete record"
  end
end
