import $ from 'jquery';
import 'select2';


// HARBOURS

// select2 field selections (1a)
$('#select2_harbours').select2({
    placeholder: "Ecrivez ou sélectionnez pour filtrer",
    allowClear: true
});
// requiring CSS (1b)
import 'select2/dist/css/select2.css';

// "submit" event listener (2)
$('#select2_harbours').on("change", (event) => {
  buildDataHash();
});

// built data in hash (3)
function buildDataHash() {
  let values = [];
  $('#select2_harbours').find("option:selected").each(function(i, selected){
    values[i] = $(selected).text();
  });
  console.log("harbours after selected = " + values);
  // calling ajax -> (4)
  callAjax(values);
}

// call ajax get (4)
function callAjax(values) {
  $.get({
    url: '/harbours',
    dataType: "script",
    data: {name: values}
  });
}


// YEARS

$('#select2_years').select2({ // TBU for each filter
    placeholder: "Ecrivez ou sélectionnez pour filtrer",
    allowClear: true
});
import 'select2/dist/css/select2.css';

// event listener for each new selected year
$('#select2_years').on("change", (event) => { // TBU for each filter
// take ALL the (un)selected year
  let values = [];
  $(event.currentTarget).find("option:selected").each(function(i, selected){
    values[i] = $(selected).text();
  });
  console.log("years after selected = " + values);
  // call ajax get
  $.get({
    url: '/harbours',
    dataType: "script",
    data: {year: values} // TBU for each filter
  });
});


// console.log(event);
// console.log(event.params);
// console.log(event.params.data);
// var harbourSelected = event.params.data.text;
// console.log(harbourSelected); // -> bayonne  -> OK

// (1a): $ = document.querySelectorAll(...) for jquery plugin, and call select2 on it
// (1b): == importing CSS! Path is relative to ./node_modules
//       CSS included in JS (not in asset pipeline) and available in / compiled by Webpack

// (3): Note: $(event.currentTarget ).find... -> event.currentTarget == '#select2_harbours'
