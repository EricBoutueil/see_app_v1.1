import $ from 'jquery';
import 'select2';
import 'select2/dist/css/select2.css';

import { log } from "./console_log";

function initializeMapFilters() {
  // (1a) select2 fields and selections management
  // harbours --> no (default) selection in filter = all harbours selected
  $('#select2_harbours').select2({
    placeholder: "Tapez les premières lettres…",
    allowClear: true,
    sorter: function(data) {
        /* Sort options ASC using lowercase comparison */
        return data.sort(function (a, b) {
            a = a.text.toLowerCase();
            b = b.text.toLowerCase();
            if (a > b) {
                return 1;
            } else if (a < b) {
                return -1;
            }
            return 0;
        });
    }
  });

  // [TBC Colin] : certainly maxYears retrieval can be optimized, but not sure it is helping for speed :)
  // years --> default selection = maxYears (from dataset temp_years in index.html.erb)
  var maxYears = document.getElementById('temp_years').dataset.temp;
  $('#select2_years').select2({
    placeholder: "Valeur par défaut: dernière année disponible",
    //allowClear: true
  // });
    sorter: function(data) {
        /* Sort options DESC using lowercase comparison */
        return data.sort(function (a, b) {
            a = a.text.toLowerCase();
            b = b.text.toLowerCase();
            if (a < b) {
                return 1;
            } else if (a > b) {
                return -1;
            }
            return 0;
        });
    }
  }).select2('val', [maxYears]);

  // flows --> default selection = enum flow 'tot' value (from type.rb)
  // note: if no 'tot' line in DB for a given harbour, 'tot' = sum of 'imp' + 'exp' (from harbour.rb (3))
  $('#select2_flows').select2({
    sorter: function(data) {
        /* Sort options DESC using lowercase comparison */
        return data.sort(function (a, b) {
            a = a.text.toLowerCase();
            b = b.text.toLowerCase();
            if (a < b) {
                return 1;
            } else if (a > b) {
                return -1;
            }
            return 0;
        });
    }
  }).select2('val', ['tot']);

  // families --> default selection = label "tonnage total brut" = ordered (from type.rb) = code A
  $('#select2_families').select2();

  // subfamilies1 --> no default selection = no subfam filter to volume calculation
  $('#select2_subfamilies1').select2({
    placeholder: "Optionnel",
    allowClear: true,
  });

  // subfamilies2
  $('#select2_subfamilies2').select2({
    placeholder: "Optionnel",
    allowClear: true,
  });

  // subfamilies3
  $('#select2_subfamilies3').select2({
    placeholder: "Optionnel",
    allowClear: true,
  });

  // *********************************************************************

  // [TBC COLIN 1]
  // AVOID 2a below = first ajax call => make a default selection for filters: selected => displayed as such:
  // harbours/"ports": none selected => all displayed
  // years/"année": maxYears selected => maxYears data displayed
  // flows/["total / import / export"]: Total selected => tot if exist or imp + exp displayed
  // families/"trafic": "tonnage brut total" selected = code A displayed
  // subfamilies/"Filtre [1 - 3]": none selected => no filter applied to volume calculation

  // (2a) initial build => AUTOMATIC FIRST AJAX CALL to ensure default data in params
  buildData();

  // (2b) event listeners for buildData and resetSubfamilies
  $('#select2_harbours').on("change", (event) => { // harbours
    buildData(); // -> (3)
  });
  $('#select2_years').on("change", (event) => { // years
    buildData(); // -> (3)
  });
  $('#select2_flows').on("change", (event) => { // flows
    buildData(); // -> (3)
  });
  $('#select2_families').on("change", (event) => { // families -> see below
    resetSubfamilies1(); // -> (pre-3.1)
    resetSubfamilies2(); // -> (pre-3.2)
    resetSubfamilies3(); // -> (pre-3.3)
  });
  $('#select2_subfamilies1').on("change", (event) => { // subfamilies1
    resetSubfamilies2(); // -> (pre-3.2)
    resetSubfamilies3(); // -> (pre-3.3)
  });
  $('#select2_subfamilies2').on("change", (event) => { // subfamilies2
    resetSubfamilies3(); // -> (pre-3.3)
  });
  $('#select2_subfamilies3').on("change", (event) => { // subfamilies2
    buildData(); // -> (3)
  });

  // *********************************************************************

  // (pre-3.1) when selecting families
  function resetSubfamilies1() {
    log("***** reseting subfamilies *****");
    // deselect all subfamilies1 selections
    $('#select2_subfamilies1').val(null);
    // empty subfamilies1 options
    $('#select2_subfamilies1').empty();
  }

  // (pre-3.2) same for subfam2 with families or subfam1
  function resetSubfamilies2() {
    $('#select2_subfamilies2').val(null);
    $('#select2_subfamilies2').empty();
  }

  // (pre-3.3) same for subfam3 + trigger change (-> build data)
  function resetSubfamilies3() {
    $('#select2_subfamilies3').val(null).trigger('change');
    $('#select2_subfamilies3').empty();
  }

  // [TBC COLIN 2]
  // Should that be optimized for loading speed?
  // (3) build harbours data in hash + execution
  function buildData() {
    log('***** building data *****');
    // harbours
    var harbours = []
    $('#select2_harbours').find("option:selected").each(function(i, selected){
      harbours[i] = $(selected).text().toLowerCase();
    });
    log("harbours selection(s) = " + harbours);

    // years
    var years = []
    $('#select2_years').find("option:selected").each(function(i, selected){
      years[i] = $(selected).text();
    });
    log("years selection(s) = " + years);

    // flows
    var flows = []
    flows = $('#select2_flows').select2('data').map(fl => fl.id);
    log("flows selection(s) = " + flows);

    // codes = families + all subfamilies
    // level0: families
    // codes = $('#select2_families').select2('data').map(c => c.id);
    var fam = []
    fam = $('#select2_families').select2('data').map(c => c.id);
    // level1: subfamilies1
    var sub_one = []
    $('#select2_subfamilies1').find("option:selected").each(function(i, selected){
      sub_one[i] = $(selected).attr("value"); // overwrite families
    });
    // level2: subfamilies2
    var sub_two = []
    $('#select2_subfamilies2').find("option:selected").each(function(j, selected){
     sub_two[j] = $(selected).attr("value"); // add to subfamilies1 (+overwrite families & parent sub1)
    });
    // level3: subfamilies3
    var sub_three = []
    $('#select2_subfamilies3').find("option:selected").each(function(k, selected){
     sub_three[k] = $(selected).attr("value"); // add to subfamilies1&2 (+overwrite families & parent sub1&2)
    });
    log("codes selection(s) = " + fam + ";" + sub_one + ";" + sub_two + ";" + sub_three);

    // data in values:
    var values = {harbours, years, flows, fam, sub_one, sub_two, sub_three}; // all
    // log("values = " + values);

    callAjax(values); // -> (4)
  }

  // *********************************************************************

  // (4) ajax get to harbours
  function callAjax(values) {
    var dataAjax = {
      name: values.harbours,
      year: values.years,
      flow: values.flows,
      fam: values.fam,
      sub_one: values.sub_one,
      sub_two: values.sub_two,
      sub_three: values.sub_three
    }
    $.get({
      url: '/harbours',
      dataType: "script",
      data: dataAjax // all
    });
    log("ajax harbours data:");
    log(dataAjax);
  }

  // *********************************************************************

  // Notes:
  // log(event);
  // log(event.params);
  // log(event.params.data);
  // var harbourSelected = event.params.data.text;
  // log(harbourSelected); // -> bayonne  -> OK
  // (1a): $ = document.querySelectorAll(...) for jquery plugin, and call select2 on it
  // (1b): == importing CSS! Path is relative to ./node_modules
  //       CSS included in JS (not in asset pipeline) and available in / compiled by Webpack
  // (3):  $(event.currentTarget ).find... -> event.currentTarget == '#select2_harbours'
}

if (document.getElementById('map_filters')) {
  initializeMapFilters();
}
