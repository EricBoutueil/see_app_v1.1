ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

require "minitest/mock"

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
end

require "webmock/minitest"
WebMock.disable_net_connect!(allow_localhost: true)


def stub_geocoder_fixtures
  stub_request(:get, "https://maps.googleapis.com/maps/api/geocode/json?address=port%20ajaccio,%20ajaccio,%20France&key=&language=en&sensor=false").
    to_return(status: 200, body: file_fixture("ajaccio.json"))

  stub_request(:get, "https://maps.googleapis.com/maps/api/geocode/json?address=port%20bastia,%20bastia,%20France&key=&language=en&sensor=false").
    to_return(status: 200, body: file_fixture("bastia.json"))
end

def load_fixtures_files
  user_id = users(:admin).id

  stub_geocoder_fixtures

  %w[
    harbours
    types
    movements
  ].each do |name|
    file = file_fixture("#{name}.csv")
    ImportJob.perform_now(user_id, csv_file_to_named_rows(file))
  end
end

def csv_file_to_named_rows(file)
  CSV.read(file, headers: true).map(&:to_h)
end
