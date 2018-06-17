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
    # harbours
    harbour_scope = policy_scope(Harbour)

    harbour_scope = scope.where(name: params[:name]) if params[:name].present?

    sel_harb_with_vol = harbour_scope.select do |harb|
      harb.totvol_filter(params) > 0
    end

    features = sel_harb_with_vol.map do |harb|
      {
        "type": "Feature", # 1 feature ~ 1 harbour where "movements.filtered.sum"
        "properties": {
          "country": harb.country,
          "name": harb.name,
          "address": harb.address,
          "totvol": harb.totvol_filter(params),
          "unit": harb.filtered_family_unit(params)
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
