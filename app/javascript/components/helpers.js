var DEBUG = window.location.href.indexOf("localhost") >= 0;

export function debug(...args) {
  if (DEBUG) {
    console.log(...args);
  }
}
