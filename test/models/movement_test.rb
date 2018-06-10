require 'test_helper'

class MovementTest < ActiveSupport::TestCase
  setup do
    load_fixtures_files
  end

  test ".all_years returns distinct years" do
    assert_equal [2014, 2015, 2016], Movement::all_years
  end
end
