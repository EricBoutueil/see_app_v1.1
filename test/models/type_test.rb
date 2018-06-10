require 'test_helper'

class TypeTest < ActiveSupport::TestCase
  setup do
    load_fixtures_files
  end

  test ".all_families returns only families with code & labels" do
    expected = [
      { code: "a", label: "tonnage brut total" },
      { code: "b", label: "conteneurs (nombres)" },
    ]

    assert_equal expected, Type::all_families
  end
end
