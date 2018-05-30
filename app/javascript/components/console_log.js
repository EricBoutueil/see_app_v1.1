if(window.location.href.indexOf("localhost") >= 0) {
   window.DEBUG = true;
}

function log(a, b, c, d) {
  if(DEBUG) {
    console.log(a, b, c, d);
  }
}

export { log };
// NOTE / TO DO: NOT ABLE TO IMPORT FUNCTIONS FROM WEBPACK FILES INTO INDEX.JS.ERB
// --> any update here need to be done there too
