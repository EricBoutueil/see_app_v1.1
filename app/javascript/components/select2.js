import $ from 'jquery';
import 'select2';

// (1a) select2 fields and selections management
$('#select2_harbours').select2({ // harbours
  placeholder: "Sélectionner ou écrire pour filtrer",
  allowClear: true
});

$('#select2_years').select2({ // years
  placeholder: "Valeur par défaut: dernière année disponible",
  allowClear: true
});

// // manually pre-select year
// }).select2('val', ['2014']);
// // attempt to automatically select max year - FAILED
// }).select2('val', ['getMaxTableau(dropDownList)']);
// // find max for years
// var dropDownList = $('#select2_years').on('select2-loaded', function(e) {
//     return e.items.results;
// });

$('#select2_flows').select2(); // flows

$('#select2_families').select2(); // families

$('#select2_subfamilies1').select2({ // subfamilies1
  placeholder: "Optionnel",
  allowClear: true
});

$('#select2_subfamilies2').select2({ // subfamilies2
  placeholder: "Optionnel",
  allowClear: true
});

// (1b) requiring CSS
import 'select2/dist/css/select2.css';

// *********************************************************************

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
$('#select2_families').on("change", (event) => { // families
  resetSubfamilies(); // -> (pre-3)
  emptySubfamilies(); // -> (pre-3)
});
$('#select2_subfamilies1').on("change", (event) => { // subfamilies1
  buildData(); // -> (3)
});
$('#select2_subfamilies2').on("change", (event) => { // subfamilies2
  buildData(); // -> (3)
});

// *********************************************************************

// (pre-3) when selecting families reset all subfamilies + trigger change
function resetSubfamilies() {
  console.log("***** reseting subfamilies *****");
  $('#select2_subfamilies1').val(null).trigger('change');
  $('#select2_subfamilies2').val(null).trigger('change');
}

// (pre-3) empty subfamilies options
function emptySubfamilies() {
  $('#select2_subfamilies1').empty();
  $('#select2_subfamilies2').empty();
}

// (3) build harbours data in hash + execution
var harbours = [];
var years = [];
var flows = [];
var codes = [];
var count_i = 0;
var count_j = 0;
var values = {};

function buildData() {
  console.log('***** building data *****');
  // harbours
  $('#select2_harbours').find("option:selected").each(function(i, selected){
    harbours[i] = $(selected).text();
  });
  console.log("harbours selection(s) = " + harbours);

  // years
  $('#select2_years').find("option:selected").each(function(i, selected){
    years[i] = $(selected).text();
  });
  console.log("years selection(s) = " + years);

  // flows
  flows = $('#select2_flows').select2('data').map(fl => fl.id);
  console.log("flows selection(s) = " + flows);

  // codes = families + all subfamilies
  // level0: families
  codes = $('#select2_families').select2('data').map(c => c.id);
  // level1: subfamilies1
  $('#select2_subfamilies1').find("option:selected").each(function(i, selected){
    codes[i] = $(selected).attr("value"); // overwrite families
    count_i = i
  });
  // level2: subfamilies2
  $('#select2_subfamilies2').find("option:selected").each(function(j, selected){
   codes[count_i + 1 + j] = $(selected).attr("value"); // add to subfamilies1 (+overwrite families)
   count_j = j
  });
  console.log("codes selection(s) = " + codes);

  // data in values:
  values = {harbours, years, flows, codes}; // all
  // console.log("values = " + values);

  callAjax(values); // -> (4)
}

// *********************************************************************

// (4) ajax get to harbours
function callAjax(values) {
  $.get({
    url: '/harbours',
    dataType: "script",
    data: {name: values.harbours, year: values.years, flow: values.flows, code: values.codes} // all
  });
  console.log("ajax harbours data:");
  console.log({name: values.harbours, year: values.years, flow: values.flows, code: values.codes});
}

// *********************************************************************

// Notes:
// console.log(event);
// console.log(event.params);
// console.log(event.params.data);
// var harbourSelected = event.params.data.text;
// console.log(harbourSelected); // -> bayonne  -> OK
// (1a): $ = document.querySelectorAll(...) for jquery plugin, and call select2 on it
// (1b): == importing CSS! Path is relative to ./node_modules
//       CSS included in JS (not in asset pipeline) and available in / compiled by Webpack
// (3):  $(event.currentTarget ).find... -> event.currentTarget == '#select2_harbours'
