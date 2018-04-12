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

// (2b) "submit" event listeners
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
  buildData();
});
$('#select2_subfamilies1').on("change", (event) => { // subfamilies1
  buildData();
});

// (3) built data in hash
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

  var codes = []; // codes = families + subfamilies1
  codes = $('#select2_families').select2('data').map(c => c.id);
  $('#select2_subfamilies1').find("option:selected").each(function(i, selected){
    codes[i] = $(selected).attr("value"); // overwrite families
  });
  console.log("codes selection(s) = " + codes);

  // var codes = []; // codes = families + subfamilies2
  // codes = $('#select2_families').select2('data').map(c => c.id);
  // $('#select2_subfamilies2').find("option:selected").each(function(i, selected){
  //   codes[i+1] = $(selected).attr("value"); // add to subfamilies1 (+overwrite families)
  // });
  // console.log("codes selection(s) = " + codes);

  var values = {harbours, years, flows, codes}; // all
  // console.log(values);

  // calling ajax -> (4)
  callAjax(values);
}

// (4) call ajax get
function callAjax(values) {
  $.get({
    url: '/harbours',
    dataType: "script",
    data: {name: values.harbours, year: values.years, flow: values.flows, code: values.codes} // all
  });
  // console.log({name: values.harbours, year: values.years});
}


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
