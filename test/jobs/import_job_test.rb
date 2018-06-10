require 'test_helper'

class ImportJobTest < ActiveJob::TestCase
  setup do
    @user = users(:admin)
  end

  test "import create harbours in db" do
    file = file_fixture("harbours.csv")

    stub_geocoder_fixtures

    assert_difference "Harbour.count", +2 do
      ImportJob.perform_now(@user.id, csv_file_to_named_rows(file))
    end

    assert Harbour.exists?(name: "ajaccio", address: "ajaccio", country: "France")
    refute Harbour.exists?(name: "nice", address: "nice", country: "France")
  end

  test "import create types in db" do
    file = file_fixture("types.csv")

    assert_difference "Type.count", +6 do
      ImportJob.perform_now(@user.id, csv_file_to_named_rows(file))
    end

    assert Type.exists?(code: "a", label: "tonnage brut total", flow: "imp")
    assert Type.exists?(code: "a", label: "tonnage brut total", flow: "exp")
  end

  test "import create movements in db" do
    file = file_fixture("movements.csv")

    stub_geocoder_fixtures
    ImportJob.perform_now(@user.id, csv_file_to_named_rows(file_fixture("harbours.csv")))
    ImportJob.perform_now(@user.id, csv_file_to_named_rows(file_fixture("types.csv")))

    assert_difference "Movement.count", +6 do
      ImportJob.perform_now(@user.id, csv_file_to_named_rows(file))
    end

    ajaccio = Harbour.find_by!(name: "ajaccio")

    assert_equal 2, Movement.where(harbour: ajaccio).count
    assert_equal 1, Movement.where(volume: 500).count
  end

  test "notify the user when an error occurs" do
    # these rows are invalid: the job will fail
    rows = [
      ["marseille", 5, 15],
      ["sete", 10, 50],
    ]

    ImportJob.perform_now(@user.id, rows)

    email = ActionMailer::Base.deliveries.last
    assert_not_nil email
    assert_equal [@user.email], email.to
    assert_match "Échec", email.subject
    # current file name will be in the exception backtrace
    assert_match __FILE__, email.html_part.body.to_s
  end
end
