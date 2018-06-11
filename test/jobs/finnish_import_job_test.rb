require 'test_helper'

class FinnishImportJobTest < ActiveJob::TestCase
  attr_reader :user
  setup do
    @user = users(:admin)
  end

  test "fix latitudes/longitudes as expected, find harbours with lower names" do
    h1 = Harbour.create!(
      name: "Pointe-à-Pitre",
      latitude: 58,
      longitude: -49.12,
      address: "fake address",
      country: "FR"
    )

    h2 = Harbour.create!(
      name: "Fort-de-France",
      latitude: 13,
      longitude: 25.13,
      address: "another address",
      country: "FR"
    )

    FinnishImportJob.perform_now(@user.id)

    h1.reload
    h2.reload

    assert_equal(48, h1.latitude)
    assert_equal(47, h2.latitude)

    assert_equal(-6.95, h1.longitude)
    assert_equal(-6.95, h2.longitude)
  end

  test "user got an email" do
    FinnishImportJob.perform_now(@user.id)

    email = ActionMailer::Base.deliveries.last
    assert_not_nil email
    assert_equal [@user.email], email.to
    assert_equal "L'import est terminé", email.subject
  end
end
