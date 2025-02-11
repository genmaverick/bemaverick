if (!Date.now)
    Date.now = function() {
        return new Date().getTime();
    };
(function() {
    var n = ["webkit", "moz"];
    for (var e = 0; e < n.length && !window.requestAnimationFrame; ++e) {
        var i = n[e];
        window.requestAnimationFrame = window[i + "RequestAnimationFrame"];
        window.cancelAnimationFrame = window[i + "CancelAnimationFrame"] || window[i + "CancelRequestAnimationFrame"];
    }
    if (/iP(ad|hone|od).*OS 6/.test(window.navigator.userAgent) || !window.requestAnimationFrame || !window.cancelAnimationFrame) {
        var a = 0;
        window.requestAnimationFrame = function(n) {
            var e = Date.now();
            var i = Math.max(a + 16, e);
            return setTimeout(function() {
                n((a = i));
            }, i - e);
        };
        window.cancelAnimationFrame = clearTimeout;
    }
})();
