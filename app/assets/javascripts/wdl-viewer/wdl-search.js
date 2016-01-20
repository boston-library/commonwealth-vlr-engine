/* functions in the WDL namespace used by WDL-Viewer */
"undefined" == typeof WDL && (window.WDL = {}), WDL.ajaxRetry = function(e) {
    "use strict";
    return e.dataType = e.dataType || "json", e.tries = 0, e.timeout = e.timeout || 15e3, e.retryLimit = e.retryLimit || 3, e.error = function(e, t) {
        (e.status >= 500 || "timeout" == t) && this.tries++ <= this.retryLimit && jQuery.ajax(this)
    }, jQuery.ajax(e)
}, WDL.Search = (function () {
    'use strict';

    function matchesTerm(haystack, needle) {
        var key = haystack.toLocaleLowerCase();
        return key.indexOf(needle.toLocaleLowerCase()) > -1;
    }

    function inTerms(a, b) {
        for (var i = 0; i < b.length; i++) {
            if (matchesTerm(a, b[i])) {
                return true;
            }
        }
        return false;
    }

    function formatPercentage(i) {
        // Take a float between 0.0 and 1.0 a string percentage suitable for CSS:
        return Math.round(100 * i).toString() + '%';
    }

    return {
        inTerms: inTerms,
        formatPercentage: formatPercentage
    };
})();