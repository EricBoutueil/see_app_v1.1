require 'test_helper'
require 'harbours_params_extractor'

class HarboursParamsExtractorTest < ActiveSupport::TestCase
  setup do
    load_fixtures_files

    @params = {
      name: ["bastia", "marseille"],
      year: ["2014", "2015"],
      flow: "imp",
      fam: "d",
    }

    @extractor = HarboursParamsExtractor.new(build_params(@params))
  end

  test "works as expected with no param, with default value" do
    extractor = HarboursParamsExtractor.new(build_params({}))
    assert_nil extractor.extract.name
    assert_equal [2016], extractor.extract.years
    assert_nil extractor.extract.flow
    assert_equal "a", extractor.extract.code
  end

  test "returns the name as it if given" do
    assert_equal %w[bastia marseille], @extractor.extract.name
  end

  test "returns the year as integer if it's valid" do
    assert_equal [2014, 2015], @extractor.extract.years
  end

  test "handle single year input param" do
    extractor = HarboursParamsExtractor.new(build_params(@params.merge(year: "2015")))
    assert_equal [2015], extractor.extract.years
  end

  test "ignore invalid year" do
    extractor = HarboursParamsExtractor.new(build_params(@params.merge(year: ["2015", "2019"])))
    assert_equal [2015], extractor.extract.years
  end

  test "returns the flow is valid" do
    Type.flows.keys.each do |flow|
      assert_equal flow, HarboursParamsExtractor.new(build_params({ flow: flow })).extract.flow
    end
  end

  test "handle flow as an array" do
    assert_equal "exp", HarboursParamsExtractor.new(build_params({ flow: ["exp"] })).extract.flow
  end

  test "returns the given family as a code" do
    assert_equal "d", @extractor.extract.code
  end

  test "returns the default code when family has more than 1 letter" do
    assert_equal "a",  HarboursParamsExtractor.new(build_params({ fam: "cd" })).extract.code
  end

  test "sub_one parameter replace the fam code" do
    params = build_params({ fam: "b", sub_one: ["cd", "ef"] })
    assert_equal ["cd", "ef"], HarboursParamsExtractor.new(params).extract.code
  end

  test "sub_two merged with sub_one, without duplicate of 2 first chars" do
    params = build_params({ fam: "b", sub_one: ["cd", "efg"], sub_two: ["cde", "hij"] })
    assert_equal ["cde", "hij", "efg"], HarboursParamsExtractor.new(params).extract.code
  end

  test "sub_three merged with sub_two, without duplicate of 3 first chars" do
    params = build_params({ fam: "b", sub_one: ["cd"], sub_two: ["cde", "efg"], sub_three: ["cdef", "hijk"] })
    assert_equal ["cdef", "hijk", "efg"], HarboursParamsExtractor.new(params).extract.code
  end

  private

  def build_params(params)
    ActionController::Parameters.new(params)
  end
end
