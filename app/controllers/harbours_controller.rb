class HarboursController < ApplicationController

  skip_before_action :authenticate_user!, only: [:index]

  def index
    # harbours
    @harbours = policy_scope(Harbour)

    @selected_harbours = Harbour.filter_by_harbour(params, @harbours)

    @sel_harb_with_vol = @selected_harbours.select do |harb|
      harb.totvol_filter(params) > 0
    end

    @features = @sel_harb_with_vol.map do |harb|
      {
        "type": "Feature", # 1 feature ~ 1 harbour where "movements.filtered.sum"
        "properties": {
          "country": harb.country,
          "name": harb.name,
          "address": harb.address,
          "totvol": harb.totvol_filter(params)
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
        "features": @features
      }

    # other instance variables
    @years = Movement::all_years

    @families = Type::all_families

    # rendering
    respond_to do |format|
      format.html
      format.js  # <-- will render `app/views/harbours/index.js.erb`
    end

  end
end
