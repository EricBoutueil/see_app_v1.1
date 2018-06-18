require 'harbours_params_extractor'
require 'harbours_filters'

class HarboursController < ApplicationController

  skip_before_action :authenticate_user!, only: [:index, :geojson]
  skip_after_action :verify_authorized, only: [:geojson]
  before_action :set_subfamilies, only: [:index, :geojson]

  def index
    @harbours = policy_scope(Harbour).pluck(:name)

    # other instance variables for filters options in index.html.erb
    @years = Movement::all_years

    @flows = Type::all_flows

    @families = Type::all_families
  end

  def geojson
    params_extractor = HarboursParamsExtractor.new(params)

    filters = HarboursFilters.new(policy_scope(Harbour), policy_scope(Movement), params_extractor.extract)

    features = filters.harbours.map do |harb|
      {
        "type": "Feature", # 1 feature ~ 1 harbour where "movements.filtered.sum"
        "properties": {
          "country": harb.country,
          "name": harb.name,
          "address": harb.address,
          "totvol": harb.filtered_volume,
          "unit": harb.filtered_unit,
        },
        "geometry": {
          "type": "Point",
          "coordinates": [harb.longitude, harb.latitude]
        },
        "id": harb.id
      }
    end

    @geojson =
      {
        "type": "FeatureCollection",
        "features": features
      }
  end

  private

  def set_subfamilies
    # only show subfamilies depending on selected higher level
    @subfamilies1 = Type::filtered_subfamilies1(params)
    @subfamilies2 = Type::filtered_subfamilies2(params)
    @subfamilies3 = Type::filtered_subfamilies3(params)
  end
end
