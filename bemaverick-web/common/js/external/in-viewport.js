(function(v) {
    var k;
    "undefined" !== typeof window ? (k = window) : "undefined" !== typeof self && (k = self);
    k.inViewport = v();
})(function() {
    return (function k(p, m, d) {
        function r(f, n) {
            if (!m[f]) {
                if (!p[f]) {
                    var c = "function" == typeof require && require;
                    if (!n && c) return c(f, !0);
                    if (t) return t(f, !0);
                    c = Error("Cannot find module '" + f + "'");
                    throw ((c.code = "MODULE_NOT_FOUND"), c);
                }
                c = m[f] = { exports: {} };
                p[f][0].call(
                    c.exports,
                    function(d) {
                        var c = p[f][1][d];
                        return r(c ? c : d);
                    },
                    c,
                    c.exports,
                    k,
                    p,
                    m,
                    d
                );
            }
            return m[f].exports;
        }
        for (var t = "function" == typeof require && require, n = 0; n < d.length; n++) r(d[n]);
        return r;
    })(
        {
            1: [
                function(k, p, m) {
                    (function(d) {
                        function k(b, a, d) {
                            b.attachEvent ? b.attachEvent("on" + a, d) : b.addEventListener(a, d, !1);
                        }
                        function m(b, a, d) {
                            var e;
                            return function() {
                                var l = this,
                                    c = arguments,
                                    h = d && !e;
                                clearTimeout(e);
                                e = setTimeout(function() {
                                    e = null;
                                    d || b.apply(l, c);
                                }, a);
                                h && b.apply(l, c);
                            };
                        }
                        function n(b, a, c) {
                            function e(a, b, d) {
                                return {
                                    watch: function() {
                                        h.add(a, b, d);
                                    },
                                    dispose: function() {
                                        h.remove(a);
                                    }
                                };
                            }
                            function l(a, e) {
                                if (!(a && u(d.document.documentElement, a) && u(d.document.documentElement, b) && a.offsetWidth && a.offsetHeight)) return !1;
                                var c = a.getBoundingClientRect();
                                if (b === d.document.body) {
                                    var l = -e;
                                    var h = -e;
                                    var f = d.document.documentElement.clientWidth + e;
                                    var g = d.document.documentElement.clientHeight + e;
                                } else (g = b.getBoundingClientRect()), (l = g.top - e), (h = g.left - e), (f = g.right + e), (g = g.bottom + e);
                                return c.right >= h && c.left <= f && c.bottom >= l && c.top <= g;
                            }
                            var h = f(),
                                g = b === d.document.body ? d : b,
                                q = m(
                                    h.checkAll(function(a, e, b) {
                                        l(a, e) && (h.remove(a), b(a));
                                    }),
                                    a
                                );
                            k(g, "scroll", q);
                            g === d && k(d, "resize", q);
                            x && w(h, b, q);
                            c && setInterval(q, 150);
                            return {
                                container: b,
                                isInViewport: function(a, b, c) {
                                    if (!c) return l(a, b);
                                    a = e(a, b, c);
                                    a.watch();
                                    return a;
                                },
                                _debounce: a,
                                _failsafe: c
                            };
                        }
                        function f() {
                            function b(a) {
                                for (var b = c.length - 1; 0 <= b; b--) if (c[b][0] === a) return b;
                                return -1;
                            }
                            function a(a) {
                                return -1 !== b(a);
                            }
                            var c = [];
                            return {
                                add: function(b, d, h) {
                                    a(b) || c.push([b, d, h]);
                                },
                                remove: function(a) {
                                    a = b(a);
                                    -1 !== a && c.splice(a, 1);
                                },
                                isWatched: a,
                                checkAll: function(a) {
                                    return function() {
                                        for (var b = c.length - 1; 0 <= b; b--) a.apply(this, c[b]);
                                    };
                                }
                            };
                        }
                        function w(b, a, c) {
                            function d(a) {
                                a = g.call([], Array.prototype.slice.call(a.addedNodes), a.target);
                                return 0 < f.call(a, b.isWatched).length;
                            }
                            var h = new MutationObserver(function(a) {
                                !0 === a.some(d) && setTimeout(c, 0);
                            }),
                                f = Array.prototype.filter,
                                g = Array.prototype.concat;
                            h.observe(a, { childList: !0, subtree: !0, attributes: !0 });
                        }
                        p.exports = function(b, a, h) {
                            var e = d.document.body;
                            if (void 0 === a || "function" === typeof a) (h = a), (a = {});
                            var e = a.container || e,
                                f = a.offset || 0,
                                k = a.debounce || 15;
                            a = a.failsafe || !0;
                            for (var g = 0; g < c.length; g++)
                                if (c[g].container === e && c[g]._debounce === k && c[g]._failsafe === a) return c[g].isInViewport(b, f, h);
                            return c[c.push(n(e, k, a)) - 1].isInViewport(b, f, h);
                        };
                        var c = [],
                            x = "function" === typeof d.MutationObserver,
                            u = function() {
                                return d.document
                                    ? d.document.documentElement.compareDocumentPosition
                                      ? function(b, a) {
                                            return !!(b.compareDocumentPosition(a) & 16);
                                        }
                                      : d.document.documentElement.contains
                                        ? function(b, a) {
                                              return b !== a && (b.contains ? b.contains(a) : !1);
                                          }
                                        : function(b, a) {
                                              for (; (a = a.parentNode); ) if (a === b) return !0;
                                              return !1;
                                          }
                                    : !0;
                            };
                    }.call(this, "undefined" !== typeof global ? global : "undefined" !== typeof self ? self : "undefined" !== typeof window ? window : {}));
                },
                {}
            ]
        },
        {},
        [1]
    )(1);
});
