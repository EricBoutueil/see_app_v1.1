// steps: if no filter -> (1) selected harbours, (2) harbours max year,
// (3) A (and/or 4) all sub fam, (5) tot flux (or exp + imp) [, (6) term, (7) pol_pod]


import $ from 'jquery';
import 'select2';

// import '../packs/map'


// HARBOURS

// select2 field only
// $ = document.querySelectorAll(...) for jquery plugin, and call select2 on it
$('#select2_harbours').select2({
    placeholder: "Ecrivez ou sélectionnez pour filtrer",
    allowClear: true
});
// Requiring CSS == importing CSS! Path is relative to ./node_modules
// CSS included in JS (not in asset pipeline) and available in / compiled by Webpack
import 'select2/dist/css/select2.css';

// event listener for each new selected harbour
$('#select2_harbours').on("select2:select", (event) => {
// take ALL the (un)selected harbour
  let values = [];
  $(event.currentTarget).find("option:selected").each(function(i, selected){
    values[i] = $(selected).text();
  });
  console.log("harbours after selected = " + values);
  // call ajax get
  $.get({
    url: '/harbours',
    dataType: "script",
    data: {name: values}//harbourSelected}
  });
});

// event listener for each new UNselected harbour
$('#select2_harbours').on("select2:unselect", (event) => {
// take ALL the (un)selected harbour
  let values = [];
  $(event.currentTarget).find("option:selected").each(function(i, selected){
    values[i] = $(selected).text();
  });
  console.log("harbours after unselected = " + values);
  // call ajax get
  $.get({
    url: '/harbours',
    dataType: "script",
    data: {name: values}
  });
});


// YEARS

$('#select2_years').select2({ // TBU for each filter
    placeholder: "Ecrivez ou sélectionnez pour filtrer",
    allowClear: true
});
import 'select2/dist/css/select2.css';

// event listener for each new selected year
$('#select2_years').on("select2:select", (event) => { // TBU for each filter
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

// event listener for each new UNselected year
$('#select2_years').on("select2:unselect", (event) => { // TBU for each filter
// take ALL the (un)selected year
  let values = [];
  $(event.currentTarget).find("option:selected").each(function(i, selected){
    values[i] = $(selected).text();
  });
  console.log("years after unselected = " + values);
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
