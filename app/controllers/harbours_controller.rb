class HarboursController < ApplicationController

  skip_before_action :authenticate_user!, only: [:index]

  def index
    # harbours
    @harbours = policy_scope(Harbour)

    @selected_harbours = Harbour.filter_by_harbour(params, @harbours)

    @features = @selected_harbours.map do |selharbour|
      {
        "type": "Feature", #1 feature ~ 1 harbour where (movements.filter).sum
        "properties": {
          "country": selharbour.country,
          "name": selharbour.name,
          "address": selharbour.address,
          "totvol": selharbour.totvol_filter(params) # harbour.totvol_filter == harbour.movements.types.where(flow: flow, code: code) # total sum to calculate
        },
        "geometry": {
          "type": "Point",
          "coordinates": [selharbour.longitude, selharbour.latitude]
        },
        "id": selharbour.id
      }
    end

    @geojson =
      {
        "type": "FeatureCollection",
        "features": @features
      }

    # respond_to
    respond_to do |format|
      format.html
      format.js  # <-- will render `app/views/harbours/index.js.erb`
    end

  end
end
