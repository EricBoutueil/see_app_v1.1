require 'test_helper'
require 'harbours_filters'
require 'harbours_params_extractor'

class HarboursFiltersTest < ActiveSupport::TestCase
  setup do
    load_fixtures_files
  end

  test "returns all ports in default year without param" do
    harbours = filters_for({}).harbours

    assert_equal %w[ajaccio bastia sete], harbours.map(&:name)
  end

  test "returns ports for a given year" do
    harbours = filters_for({ year: "2015" }).harbours

    assert_equal %w[ajaccio sete], harbours.map(&:name)
  end

  test "filters by name" do
    harbours = filters_for({ name: %w[bastia sete] }).harbours

    assert_equal %w[bastia sete], harbours.map(&:name)

    assert_empty filters_for({ name: %w[clermont] }).harbours
  end

  test "filters by imp/exp flow" do
    harbours = filters_for({ flow: "imp", year: "2014" }).harbours
    assert_equal %w[ajaccio bastia], harbours.map(&:name)

    harbours = filters_for({ flow: "exp", year: "2014"  }).harbours
    assert_equal %w[bastia], harbours.map(&:name)
  end

  test "computed volume takes only imp or exp for theses filters" do
    harbours = filters_for({ flow: "imp", year: "2015", fam: "a", sub_one: ["a1"], sub_two: %w[a11 a13] }).harbours


    assert_nil harbours.find { |h| h.name == "ajaccio" }

    assert_equal 1_010, harbours.find { |h| h.name == "sete" }.filtered_volume
  end

  test "computed volume ignore zero volume" do
    harbours = filters_for({ flow: "imp", year: "2014", fam: "a" }).harbours


    assert_nil harbours.find { |h| h.name == "sete" }
    assert_equal 100_000, harbours.find { |h| h.name == "ajaccio" }.filtered_volume
  end

  test "filters by computed total flow" do
    harbours = filters_for({ flow: "tot", year: "2016", fam: "a" }).harbours

    ajaccio, bastia, sete = %w[ajaccio bastia sete].map do |name|
      harbours.find { |h| h.name == name }
    end

    assert_equal 300_000, ajaccio.filtered_volume
    assert_equal 204_000, bastia.filtered_volume
    assert_equal 3_200, sete.filtered_volume
  end

  test "filtered volume by direct total movements" do
    ajaccio = Harbour.find_by!(name: "ajaccio")

    create(:movement, harbour: ajaccio, volume: 12_500, type: create(:type))
    create(:movement, harbour: ajaccio, volume: 1_500, type: create(:type, :imp))
    create(:movement, harbour: ajaccio, volume: 1_500, type: create(:type, :exp))

    harbours = filters_for({ flow: "tot", year: "2016", fam: "b", sub_one: ["b1"] }).harbours

    assert_equal 12_500, harbours.first.filtered_volume
  end

  test "filtered volume with multiple subfilters, mixing tot & imp+exp flows" do
    ajaccio = Harbour.find_by!(name: "ajaccio")

    create(:movement, harbour: ajaccio, volume: 10_000, type: create(:type, code: "b1"))
    create(:movement, harbour: ajaccio, volume: 1_500, type: create(:type, :imp, code: "b1"))
    create(:movement, harbour: ajaccio, volume: 1_500, type: create(:type, :exp, code: "b1"))
    create(:movement, harbour: ajaccio, volume: 100, type: create(:type, :imp, code: "b2"))
    create(:movement, harbour: ajaccio, volume: 200, type: create(:type, :exp, code: "b2"))


    harbours = filters_for({ flow: "tot", year: "2016", fam: "b", sub_one: %w[b1 b2] }).harbours
    # sum must be b1 tot + b2 imp + b2 exp
    assert_equal 10_300, harbours.first.filtered_volume
  end

  test "set family unit without filtering sub families" do
    harbours = filters_for({}).harbours

    assert harbours.all? { |h| h.filtered_unit == "tonnes" }
  end

  test "set family unit with sub families" do
    ajaccio = Harbour.find_by!(name: "ajaccio")
    create(:movement, harbour: ajaccio, type: create(:type, unit: "parsec", code: "c1"))

    harbours = filters_for({ fam: "c", sub_one: "c1"}).harbours
    assert_equal "parsec", harbours.first.filtered_unit
  end

  private

  def filters_for(params)
    HarboursFilters.new(harbour_scope, movement_scope, HarboursParamsExtractor.new(params).extract)
  end

  def harbour_scope
    Pundit.policy_scope(nil, Harbour)
  end

  def movement_scope
    Pundit.policy_scope(nil, Movement)
  end
end
