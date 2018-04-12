import $ from 'jquery';
import 'select2';

// (1a) selections for select2 fields
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

// (1b) requiring CSS
import 'select2/dist/css/select2.css';


// (2a) initial build => AUTOMATIC FIRST AJAX CALL
buildData();

// (2b) event listeners for buildData and resets
$('#select2_harbours').on("change", (event) => { // harbours
  buildData();
});
$('#select2_years').on("change", (event) => { // years
  buildData();
});
$('#select2_flows').on("change", (event) => { // flows
  buildData();
});
$('#select2_families').on("change", (event) => { // families
  // buildData();
  // });
  // $('#select2_families').on("change", function() { // families
  resetSubfamilies(); // (pre-3) + (3)
});
$('#select2_subfamilies1').on("change", (event) => { // subfamilies1
  buildData();
});

// (pre-3) when selecting families reset all subfamilies + buildData + callAjaxTypes
function resetSubfamilies() {
  console.log("reseting subfamilies")
  $('#select2_subfamilies1').val(null).trigger('change');
  // $('select2_subfamilies1').each(function () {
  //     $(this).select2('val', '')
  // });

  buildData(); // (3)
  // buildDataTypes(); // (3bis)

}

// (3) build harbours data in hash + callAjax
function buildData() {
  console.log('***********************')
  var harbours = []; // harbours
  $('#select2_harbours').find("option:selected").each(function(i, selected){
    harbours[i] = $(selected).text();
  });
  console.log("harbours selection(s) = " + harbours);

  var years = []; // years
  $('#select2_years').find("option:selected").each(function(i, selected){
    years[i] = $(selected).text();
  });
  console.log("years selection(s) = " + years);

  var flows = []; // flows
  flows = $('#select2_flows').select2('data').map(fl => fl.id);
  console.log("flows selection(s) = " + flows);

  var codes = []; // codes = families + all subfamilies
  var count = 0
  // level0: families
  codes = $('#select2_families').select2('data').map(c => c.id);
  // level1: subfamilies1
  $('#select2_subfamilies1').find("option:selected").each(function(i, selected){
    codes[i] = $(selected).attr("value"); // overwrite families
    count = i
  });
  // level2: subfamilies2
  // $('#select2_subfamilies2').find("option:selected").each(function(j, selected){
  //  codes[count + j] = $(selected).attr("value"); // add to subfamilies1 (+overwrite families)
  //  count = count + j
  // });
  console.log("codes selection(s) = " + codes);

  var values = {harbours, years, flows, codes}; // all
  // console.log(values);

  // ajax get to harbours -> (4)
  callAjax(values);
}

// (4) ajax get to harbours
function callAjax(values) {
  $.get({
    url: '/harbours',
    dataType: "script",
    data: {name: values.harbours, year: values.years, flow: values.flows, code: values.codes} // all
  });
  console.log({name: values.harbours, year: values.years, flow: values.flows, code: values.codes});
}


// // (3bis) build types data in hash + callAjaxTypes
// function buildDataTypes() {
//   // ajax get to types -> (4bis)
//   // callAjaxTypes(options);
// }

// // (4bis) ajax get to types
// function callAjaxTypes(values) {
//   $.get({
//     url: '/types',
//     dataType: "script",
//     data: {name: values.harbours, year: values.years, flow: values.flows, code: values.codes} // all
//   });
//   console.log({name: values.harbours, year: values.years, flow: values.flows, code: values.codes});
// }

// console.log(event);
// console.log(event.params);
// console.log(event.params.data);
// var harbourSelected = event.params.data.text;
// console.log(harbourSelected); // -> bayonne  -> OK

// Notes:
// (1a): $ = document.querySelectorAll(...) for jquery plugin, and call select2 on it
// (1b): == importing CSS! Path is relative to ./node_modules
//       CSS included in JS (not in asset pipeline) and available in / compiled by Webpack
// (3):  $(event.currentTarget ).find... -> event.currentTarget == '#select2_harbours'
