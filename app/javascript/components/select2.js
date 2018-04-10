import $ from 'jquery';
import 'select2';

// (1a) selections for select2 fields
$('#select2_harbours').select2({ // harbours
    placeholder: "Ecrivez ou sélectionnez pour filtrer",
    allowClear: true
});

$('#select2_years').select2({ // years
    placeholder: "Ecrivez ou sélectionnez pour filtrer",
    allowClear: true
});

// (1b) requiring CSS
import 'select2/dist/css/select2.css';

// (2) "submit" event listeners
$('#select2_harbours').on("change", (event) => { // habours
  buildData();
});
$('#select2_years').on("change", (event) => { // years
  buildData();
});

// (3) built data in hash
function buildData() {
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

  var values = {harbours, years}; // all
  // console.log(values);

  // calling ajax -> (4)
  callAjax(values);
}

// (4) call ajax get
function callAjax(values) {
  $.get({
    url: '/harbours',
    dataType: "script",
    data: {name: values.harbours, year: values.years} // all
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
