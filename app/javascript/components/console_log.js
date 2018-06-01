if(window.location.href.indexOf("localhost") >= 0) {
   var DEBUG = true;
}

function log(a) {
  if(DEBUG) {
    console.log(a);
  }
}

export { log };
// NOTE / TO DO: NOT ABLE TO IMPORT FUNCTIONS FROM WEBPACK FILES INTO INDEX.JS.ERB
// --> any update here need to be done there too
