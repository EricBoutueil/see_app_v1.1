// STEP 1: init map
var mapElement = document.getElementById('map');
var map;
var mapStyle = [
  {
    "featureType": "poi",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "labels.icon",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "transit",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  }
];
function initMap() {
  if (mapElement) {
    map = new google.maps.Map(mapElement, {
          zoom: 6,
          center: {lat:46.52863469527167, lng:2.43896484375},
          // FR: {lat:46.52863469527167, lng:2.43896484375} // MRS: {lat: 43.3, lng: 5.4}
          styles: mapStyle
        });

  };
}

// STEP 2: load GeoJson
function loadGeoJson() {
  if (mapElement) {
    var jsonparsed = JSON.parse(mapElement.dataset.geojson);

    zoom();

    map.data.addGeoJson(jsonparsed);

  };
}

// auto center map on data layer
function zoom() {
    var bounds = new google.maps.LatLngBounds();
    google.maps.event.addListener(map.data, 'addfeature', function(e) {
        if (e.feature.getGeometry().getType() === 'Point') {
          bounds.extend(e.feature.getGeometry().get());
        }
        map.fitBounds(bounds);
      });
}

// STEP 3: set data style
function setFeaturesStyle() {
  if (mapElement) {
    maxTotvol();

    map.data.setStyle(function(feature) {
      var totalVolume = feature.getProperty('totvol');
      return {
        icon: getCircle(totalVolume)
      };
    });
  };
}

// calculate total volume max of filtered features
var totalVolumeMax = 0;
function maxTotvol() {
    map.data.forEach(function(feature) {
        if (feature.getProperty('totvol') > totalVolumeMax) {
          totalVolumeMax = feature.getProperty('totvol');
        };
    });
    // console.log(totalVolumeMax)
}

// show proportional markers (note: markers ares symbols == circles)
function getCircle(totalVolume) {
  return {
    path: google.maps.SymbolPath.CIRCLE,
    fillColor: 'blue',
    fillOpacity: .8,
    scale: (totalVolume * 20 / totalVolumeMax),
    strokeColor: 'blue',
    strokeWeight: 1
  };
}



// execution
initMap();
loadGeoJson();
setFeaturesStyle();

// google.maps.event.addDomListener(window, "load", initMap);
// eventListener dataset

// export { loadGeoJson, getCircle };
