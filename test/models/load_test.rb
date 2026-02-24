require "test_helper"

class LoadTest < ActiveSupport::TestCase
  test "validates status inclusion" do
    load = loads(:one)
    load.status = "unknown"

    assert_not load.valid?
    assert_includes load.errors[:status], "is not included in the list"
  end

  test "allows nil driver" do
    load = Load.new(
      reference_number: "REF-2001",
      status: "booked",
      pickup_date: Date.current,
      origin_city: "Dallas",
      dest_city: "Austin",
      rate: 500,
      customer: customers(:one),
      driver: nil
    )

    assert load.valid?
  end
end
