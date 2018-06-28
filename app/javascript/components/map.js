import { debug } from '../components/helpers';

const style = [
  {
    "elementType": "labels",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "administrative",
    "elementType": "geometry",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "administrative.country",
    "elementType": "geometry.stroke",
    "stylers": [
      {
        "visibility": "on"
      }
    ]
  },
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
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry.fill",
    "stylers": [
      {
        "visibility": "on"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry.stroke",
    "stylers": [
      {
        "visibility": "off" // on for more road on the map
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

let map;
let unit;
let unitScaleText = "";
const maxZoom = 10;
let totalVolumeMax = 0;

function initialize(mapElement) {
  if (!google || !google.maps) {
    console.error("Missing google maps module");
    return null;
  }

  map = new google.maps.Map(mapElement, {
        zoom: 6,
        maxZoom: maxZoom,
        center: {lat:46.52863469527167, lng:2.43896484375},
        styles: style,
        gestureHandling: 'greedy',
        streetViewControl: false,
        mapTypeControl: false
      });

  // add rectangle, legend, image for Outre Mer (FR)
  var rectangle = new google.maps.Rectangle({
        strokeColor: '#007A8E',
        strokeOpacity: 1,
        strokeWeight: 2,
        // fillColor: '#007A8E',
        fillOpacity: 0,
        map: map,
        bounds: {
          north: 48.5,
          south: 44.5,
          east: -6.3,
          west: -7.6
        }
      });

  // image
  // https://mapstyle.withgoogle.com/
  // parameters' scales: 1 / 1 / 0
  // sea color: R178 G219 B255 (#B2DBFF) for png on figma
  let OutreMerImageOverlay = new google.maps.GroundOverlay(
      window.sharedPaths.omi,
      {
        north: 48.4,
        south: 44.6,
        east: -6.3,
        west: -7.6
      });
  OutreMerImageOverlay.setMap(map);

  // country names
  let OutreMerNamesOverlay = new google.maps.GroundOverlay(
      window.sharedPaths.omn,
      {
        north: 48.3,
        south: 45.2,
        east: -6.3,
        west: -7.6
      });
  OutreMerNamesOverlay.setMap(map);

  setZoomListener();
}

export function initializeIfUndefined(mapElement) {
  if (map === undefined) {
    initialize(mapElement); // STEP 1
  }
}

export function setUnit(str) {
  unit = str;
}

// [TBC COLIN 3]
// auto zoom optimization of map (2.1) and retrieve/usage of zoom to caculate circles sizes (2.2 and all 3.)
// 2.1 auto center map on data layer
function zoom() {
  debug("Zoom before optimization ", map.getZoom());

  // initialize the bounds
  const bounds = new google.maps.LatLngBounds();

  const france = ['fr', 'FR', 'france', 'France', 'FRANCE'];
  let franceOnly = true;

  map.data.forEach(feature => {
    const geometry = feature.getGeometry();
    if (geometry.getType() === 'Point') {
      bounds.extend(geometry.get());

      if (!france.includes(feature.getProperty('country'))) {
        franceOnly = false;
      }
    }
  });

  debug("France only", franceOnly);

  // adapt zoom to bounds
  google.maps.event.addListenerOnce(map, 'bounds_changed', () => {
    const currentZoom = map.getZoom();
    debug("bounds changed listener, currentZoom = ", currentZoom);

    if (currentZoom < 6) {
      // [TBC COLIN 4]
      // zoom is generally set to 5 for French, which make the map uglier
      const isMobile = /iPhone|iPad|iPod|Android/i.test(navigator.userAgent);
      if (!isMobile && franceOnly) {
        debug("force zoom 6")
        map.setZoom(6);
      }
    }

    if (currentZoom > 10) { // or set a minimum
      map.setZoom(10);  // set zoom here
    }

    debug("new zoom:", map.getZoom());
  });

  // map.initialZoom = true;
  map.fitBounds(bounds, 20);
  debug("new zoom:", map.getZoom());
}

// 2.2 retrieve zoomActual (can be from zoom() or changed manually) for circles scales (3.)
function setZoomListener() {
  google.maps.event.addListener(map, 'zoom_changed', function() {
    setFeaturesStyleZoomed();
  });
}


// 2.3 show an info window when the user click on a circle
function loadInfoWindows() {
  const infowindow = new google.maps.InfoWindow();
  map.data.addListener('click', function(event) {
    const myHTML =  '<p class="infowindow-title">'+
                  event.feature.getProperty("name").replace(/(^|\s)[a-z\u00E0-\u00FC]/g, l => l.toUpperCase()) +
                  '</p>' +
                  '<p class="mb0">'+
                  event.feature.getProperty('totvol').toLocaleString(undefined) +
                  " "+
                  event.feature.getProperty('unit') +
                  '</p>'

    infowindow.setContent("<div>"+myHTML+"</div>");
    // infowindow.setContent("<div style='width:100px;'>"+myHTML+"</div>");
    // position the infowindow on the marker
    infowindow.setPosition(event.feature.getGeometry().get());
    // anchor the infowindow on the marker
    infowindow.setOptions({pixelOffset: new google.maps.Size(0,0)});
    infowindow.open(map);
  });
}


// STEP 3: set data style
// 3.0 create a circle for each feature
export function setFeaturesStyle() {
  // computeTotalVolumeMax(); // 3.1
  // getZoomBounds(); // 3.2

  map.data.setStyle(function(feature) {
    const totalVolume = feature.getProperty('totvol');
    const displayedTotalVol = displayedVol(totalVolume) // 3.3

    // debug('tot vol ' + feature.getProperty('name') +' = '+ totalVolume);
    debug('calc scale ' +feature.getProperty('name') +' = '+calcScale(totalVolume));


    return {
      icon: getCircle(totalVolume), // 3.4
      label: {
        text: displayedTotalVol,
        color: "#17375E"
      }
    };
  });
}

// 3.0bis do it for manual zoom (from 2.2):
function setFeaturesStyleZoomed() {
  // computeTotalVolumeMax(); // 3.1
  // getZoomBounds(); // 3.2 -> not updated when zoomed manually
  map.data.setStyle(function(feature) {
    const totalVolume = feature.getProperty('totvol');
    const displayedTotalVol = displayedVol(totalVolume) // 3.3
    // debug('tot vol ' + feature.getProperty('name') +' = '+ totalVolume);
    debug('***calc scale ' +feature.getProperty('name') +' = '+calcScale(totalVolume));

    return {
      icon: getCircle(totalVolume), // 3.4
      label: {
        text: displayedTotalVol,
        color: "#17375E",
        fontSize: '12px'
      }
    };
  });
}


// 3.1 calculate total volume max of filtered features (from 3.0 and 3.0bis)
function computeTotalVolumeMax() {
  totalVolumeMax = 0; // reset each time this method is called, for 2nd call and followings
  map.data.forEach(function(feature) {
    const volume = feature.getProperty('totvol');
    if (volume > totalVolumeMax) {
      totalVolumeMax = volume;
    };
  });

  debug('totalVolumeMax', totalVolumeMax);
}

// 3.2 calculate zoomBounds for circles scales (from 3.0 only)
// function getZoomBounds() {
//     zoomBounds = map.getZoom();
//     if (zoomBounds > 10) {
//       zoomBounds = 10
//     }
//
//     debug('zoom bounds', zoomBounds);
// }

// 3.3 calcl vol to display on circles (from 3.0 and 3.0bis)
function displayedVol(totalVolume) {
  // var displayedVol = (Math.round(totalVolume *100 / (maxPowTen())) / 100); // for proportional units
  let rounding;

  if (unitScaleText == " millions ") {
    rounding = (Math.round(totalVolume * 100 / 1000000) / 100);
    if (rounding < 0.01) {
      return "<0.01";
    }

    return rounding.toString();
  }

  if (unitScaleText == " milliers ") {
    rounding = (Math.round(totalVolume * 100 / 1000) / 100);
    if (rounding < 0.01) {
      return "<0.01";
    }

    return rounding.toString();
  }


  rounding = (Math.round(totalVolume * 100) / 100);
  if (rounding < 0.01) {
    return "<0.01";
  }

  return rounding.toString();
}

// 3.4 show proportional markers (note: markers ares symbols == circles)
function getCircle(totalVolume) {
  return {
    path: google.maps.SymbolPath.CIRCLE,
    fillColor: '#00bcdb',
    fillOpacity: 0.9,
    scale: calcScale(totalVolume), // 3.4.1
    strokeColor: '#17375E',
    strokeWeight: 0
  };
}

// 3.4.1 calc scale for circles scales
function calcScale(totalVolume) {
  let scale = (Math.sqrt(totalVolume * Math.pow(48, 2) / totalVolumeMax));

  if (scale < 3) {
    scale = 3;
  }

  return scale;
}

// 3.5 from 4.1 add legend (unit on top left corner of the map)
function addUnitLegend() {
  const legend = document.getElementById('legend')
  // var maxPowTenToLocaleString = maxPowTen().toLocaleString(undefined);
  // legend.innerText = `Unité : ${maxPowTenToLocaleString} ${unitSelectedFamily}`
  legend.innerText = `Unité : ${unitScaleText} ${unitSelectedFamily()}` // 3.5.1&3
  // map.controls[google.maps.ControlPosition.LEFT_TOP].push(legend)
}

// 3.5.1 calc unit from legend
function computeUnitScaleText() {
  const maxPow = maxPowTen();

  if (maxPow >= 1000000) { // 3.5.2
    unitScaleText = " millions ";
    return;
  }

  if (maxPow >= 1000) { // 3.5.2
    unitScaleText = " milliers "
    return;
  }

  unitScaleText = "";
}

// 3.5.2 calculate max displayed totalVolume pow of 10
function maxPowTen() {
  const totVolLength = totalVolumeMax.toString().length;
  return (Math.pow(10, totVolLength)) / 10;
}

// 3.5.3 identify unit family
function unitSelectedFamily() {
  // [TBC Colin 5]
  if (!unit) {
    return "";
  }

  const firstLetter = unit.substr(0, 1);
  const vowels = ["a", "e", "i", "o", "u", "y"];
  if (vowels.includes(firstLetter)){
    return `d\'${unit}`;
  }

  return `de ${unit}`;
}

export function loadGeoJson(geojson) {
  // removing previous features --> needed because not reinitiating the map (for quotas)
  map.data.forEach(function(feature) {
      map.data.remove(feature);
  });


  map.data.addGeoJson(geojson);
  computeTotalVolumeMax(); // 3.1
  computeUnitScaleText();

  zoom(); // 2.1

  loadInfoWindows(); // 2.3
}



export function loadSubfamilies(selectId, subfamilies, shouldAddUnitLegend = false) {
  const prevOptions = document.querySelectorAll(`#${selectId} option`);
  const select = document.getElementById(selectId);

  // creating new dropdown options only when selecting a new family (not when selecting subfamilies1)
  if (prevOptions.length == 0) {
    // iteration on @subfamilies1 parsed to create new dropdow options
    subfamilies.forEach(subf => {
      const newOpt = document.createElement('option');

      newOpt.value = subf.code;
      newOpt.innerText = subf.label.charAt(0).toUpperCase() + subf.label.slice(1);
      select.appendChild(newOpt);
    });
  }

  if (shouldAddUnitLegend) {
    addUnitLegend(); // 3.5
  }
}
