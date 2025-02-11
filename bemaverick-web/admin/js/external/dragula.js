!(function(e) {
    if ("object" == typeof exports && "undefined" != typeof module) module.exports = e();
    else if ("function" == typeof define && define.amd) define([], e);
    else {
        var n;
        (n = "undefined" != typeof window ? window : "undefined" != typeof global ? global : "undefined" != typeof self ? self : this), (n.dragula = e());
    }
})(function() {
    return (function e(n, t, r) {
        function o(u, c) {
            if (!t[u]) {
                if (!n[u]) {
                    var a = "function" == typeof require && require;
                    if (!c && a) return a(u, !0);
                    if (i) return i(u, !0);
                    var f = new Error("Cannot find module '" + u + "'");
                    throw ((f.code = "MODULE_NOT_FOUND"), f);
                }
                var l = (t[u] = { exports: {} });
                n[u][0].call(
                    l.exports,
                    function(e) {
                        var t = n[u][1][e];
                        return o(t ? t : e);
                    },
                    l,
                    l.exports,
                    e,
                    n,
                    t,
                    r
                );
            }
            return t[u].exports;
        }
        for (var i = "function" == typeof require && require, u = 0; u < r.length; u++) o(r[u]);
        return o;
    })(
        {
            1: [
                function(e, n, t) {
                    "use strict";
                    function r(e) {
                        var n = u[e];
                        return n ? (n.lastIndex = 0) : (u[e] = n = new RegExp(c + e + a, "g")), n;
                    }
                    function o(e, n) {
                        var t = e.className;
                        t.length ? r(n).test(t) || (e.className += " " + n) : (e.className = n);
                    }
                    function i(e, n) {
                        e.className = e.className.replace(r(n), " ").trim();
                    }
                    var u = {},
                        c = "(?:^|\\s)",
                        a = "(?:\\s|$)";
                    n.exports = { add: o, rm: i };
                },
                {}
            ],
            2: [
                function(e, n, t) {
                    (function(t) {
                        "use strict";
                        function r(e, n) {
                            function t(e) {
                                return -1 !== le.containers.indexOf(e) || fe.isContainer(e);
                            }
                            function r(e) {
                                var n = e ? "remove" : "add";
                                o(S, n, "mousedown", O), o(S, n, "mouseup", L);
                            }
                            function c(e) {
                                var n = e ? "remove" : "add";
                                o(S, n, "mousemove", N);
                            }
                            function m(e) {
                                var n = e ? "remove" : "add";
                                w[n](S, "selectstart", C), w[n](S, "click", C);
                            }
                            function h() {
                                r(!0), L({});
                            }
                            function C(e) {
                                ce && e.preventDefault();
                            }
                            function O(e) {
                                (ne = e.clientX), (te = e.clientY);
                                var n = 1 !== i(e) || e.metaKey || e.ctrlKey;
                                if (!n) {
                                    var t = e.target,
                                        r = T(t);
                                    r && ((ce = r), c(), "mousedown" === e.type && (p(t) ? t.focus() : e.preventDefault()));
                                }
                            }
                            function N(e) {
                                if (ce) {
                                    if (0 === i(e)) return void L({});
                                    if (void 0 === e.clientX || e.clientX !== ne || void 0 === e.clientY || e.clientY !== te) {
                                        if (fe.ignoreInputTextSelection) {
                                            var n = y("clientX", e),
                                                t = y("clientY", e),
                                                r = x.elementFromPoint(n, t);
                                            if (p(r)) return;
                                        }
                                        var o = ce;
                                        c(!0), m(), D(), B(o);
                                        var a = u(W);
                                        (Z = y("pageX", e) - a.left), (ee = y("pageY", e) - a.top), E.add(ie || W, "gu-transit"), K(), U(e);
                                    }
                                }
                            }
                            function T(e) {
                                if (!((le.dragging && J) || t(e))) {
                                    for (var n = e; v(e) && t(v(e)) === !1; ) {
                                        if (fe.invalid(e, n)) return;
                                        if (((e = v(e)), !e)) return;
                                    }
                                    var r = v(e);
                                    if (r && !fe.invalid(e, n)) {
                                        var o = fe.moves(e, r, n, g(e));
                                        if (o) return { item: e, source: r };
                                    }
                                }
                            }
                            function X(e) {
                                return !!T(e);
                            }
                            function Y(e) {
                                var n = T(e);
                                n && B(n);
                            }
                            function B(e) {
                                $(e.item, e.source) && ((ie = e.item.cloneNode(!0)), le.emit("cloned", ie, e.item, "copy")),
                                    (Q = e.source),
                                    (W = e.item),
                                    (re = oe = g(e.item)),
                                    (le.dragging = !0),
                                    le.emit("drag", W, Q);
                            }
                            function P() {
                                return !1;
                            }
                            function D() {
                                if (le.dragging) {
                                    var e = ie || W;
                                    M(e, v(e));
                                }
                            }
                            function I() {
                                (ce = !1), c(!0), m(!0);
                            }
                            function L(e) {
                                if ((I(), le.dragging)) {
                                    var n = ie || W,
                                        t = y("clientX", e),
                                        r = y("clientY", e),
                                        o = a(J, t, r),
                                        i = q(o, t, r);
                                    i && ((ie && fe.copySortSource) || !ie || i !== Q) ? M(n, i) : fe.removeOnSpill ? R() : A();
                                }
                            }
                            function M(e, n) {
                                var t = v(e);
                                ie && fe.copySortSource && n === Q && t.removeChild(W), k(n) ? le.emit("cancel", e, Q, Q) : le.emit("drop", e, n, Q, oe), j();
                            }
                            function R() {
                                if (le.dragging) {
                                    var e = ie || W,
                                        n = v(e);
                                    n && n.removeChild(e), le.emit(ie ? "cancel" : "remove", e, n, Q), j();
                                }
                            }
                            function A(e) {
                                if (le.dragging) {
                                    var n = arguments.length > 0 ? e : fe.revertOnSpill,
                                        t = ie || W,
                                        r = v(t),
                                        o = k(r);
                                    o === !1 && n && (ie ? r && r.removeChild(ie) : Q.insertBefore(t, re)),
                                        o || n ? le.emit("cancel", t, Q, Q) : le.emit("drop", t, r, Q, oe),
                                        j();
                                }
                            }
                            function j() {
                                var e = ie || W;
                                I(),
                                    z(),
                                    e && E.rm(e, "gu-transit"),
                                    ue && clearTimeout(ue),
                                    (le.dragging = !1),
                                    ae && le.emit("out", e, ae, Q),
                                    le.emit("dragend", e),
                                    (Q = W = ie = re = oe = ue = ae = null);
                            }
                            function k(e, n) {
                                var t;
                                return (t = void 0 !== n ? n : J ? oe : g(ie || W)), e === Q && t === re;
                            }
                            function q(e, n, r) {
                                function o() {
                                    var o = t(i);
                                    if (o === !1) return !1;
                                    var u = H(i, e),
                                        c = V(i, u, n, r),
                                        a = k(i, c);
                                    return a ? !0 : fe.accepts(W, i, Q, c);
                                }
                                for (var i = e; i && !o(); ) i = v(i);
                                return i;
                            }
                            function U(e) {
                                function n(e) {
                                    le.emit(e, f, ae, Q);
                                }
                                function t() {
                                    s && n("over");
                                }
                                function r() {
                                    ae && n("out");
                                }
                                if (J) {
                                    e.preventDefault();
                                    var o = y("clientX", e),
                                        i = y("clientY", e),
                                        u = o - Z,
                                        c = i - ee;
                                    (J.style.left = u + "px"), (J.style.top = c + "px");
                                    var f = ie || W,
                                        l = a(J, o, i),
                                        d = q(l, o, i),
                                        s = null !== d && d !== ae;
                                    (s || null === d) && (r(), (ae = d), t());
                                    var p = v(f);
                                    if (d === Q && ie && !fe.copySortSource) return void (p && p.removeChild(f));
                                    var m,
                                        h = H(d, l);
                                    if (null !== h) m = V(d, h, o, i);
                                    else {
                                        if (fe.revertOnSpill !== !0 || ie) return void (ie && p && p.removeChild(f));
                                        (m = re), (d = Q);
                                    }
                                    ((null === m && s) || (m !== f && m !== g(f))) && ((oe = m), d.insertBefore(f, m), le.emit("shadow", f, d, Q));
                                }
                            }
                            function _(e) {
                                E.rm(e, "gu-hide");
                            }
                            function F(e) {
                                le.dragging && E.add(e, "gu-hide");
                            }
                            function K() {
                                if (!J) {
                                    var e = W.getBoundingClientRect();
                                    (J = W.cloneNode(!0)),
                                        (J.style.width = d(e) + "px"),
                                        (J.style.height = s(e) + "px"),
                                        E.rm(J, "gu-transit"),
                                        E.add(J, "gu-mirror"),
                                        fe.mirrorContainer.appendChild(J),
                                        o(S, "add", "mousemove", U),
                                        E.add(fe.mirrorContainer, "gu-unselectable"),
                                        le.emit("cloned", J, W, "mirror");
                                }
                            }
                            function z() {
                                J && (E.rm(fe.mirrorContainer, "gu-unselectable"), o(S, "remove", "mousemove", U), v(J).removeChild(J), (J = null));
                            }
                            function H(e, n) {
                                for (var t = n; t !== e && v(t) !== e; ) t = v(t);
                                return t === S ? null : t;
                            }
                            function V(e, n, t, r) {
                                function o() {
                                    var n,
                                        o,
                                        i,
                                        u = e.children.length;
                                    for (n = 0; u > n; n++) {
                                        if (((o = e.children[n]), (i = o.getBoundingClientRect()), c && i.left + i.width / 2 > t)) return o;
                                        if (!c && i.top + i.height / 2 > r) return o;
                                    }
                                    return null;
                                }
                                function i() {
                                    var e = n.getBoundingClientRect();
                                    return u(c ? t > e.left + d(e) / 2 : r > e.top + s(e) / 2);
                                }
                                function u(e) {
                                    return e ? g(n) : n;
                                }
                                var c = "horizontal" === fe.direction,
                                    a = n !== e ? i() : o();
                                return a;
                            }
                            function $(e, n) {
                                return "boolean" == typeof fe.copy ? fe.copy : fe.copy(e, n);
                            }
                            var G = arguments.length;
                            1 === G && Array.isArray(e) === !1 && ((n = e), (e = []));
                            var J,
                                Q,
                                W,
                                Z,
                                ee,
                                ne,
                                te,
                                re,
                                oe,
                                ie,
                                ue,
                                ce,
                                ae = null,
                                fe = n || {};
                            void 0 === fe.moves && (fe.moves = l),
                                void 0 === fe.accepts && (fe.accepts = l),
                                void 0 === fe.invalid && (fe.invalid = P),
                                void 0 === fe.containers && (fe.containers = e || []),
                                void 0 === fe.isContainer && (fe.isContainer = f),
                                void 0 === fe.copy && (fe.copy = !1),
                                void 0 === fe.copySortSource && (fe.copySortSource = !1),
                                void 0 === fe.revertOnSpill && (fe.revertOnSpill = !1),
                                void 0 === fe.removeOnSpill && (fe.removeOnSpill = !1),
                                void 0 === fe.direction && (fe.direction = "vertical"),
                                void 0 === fe.ignoreInputTextSelection && (fe.ignoreInputTextSelection = !0),
                                void 0 === fe.mirrorContainer && (fe.mirrorContainer = x.body);
                            var le = b({ containers: fe.containers, start: Y, end: D, cancel: A, remove: R, destroy: h, canMove: X, dragging: !1 });
                            return fe.removeOnSpill === !0 && le.on("over", _).on("out", F), r(), le;
                        }
                        function o(e, n, r, o) {
                            var i = { mouseup: "touchend", mousedown: "touchstart", mousemove: "touchmove" },
                                u = { mouseup: "pointerup", mousedown: "pointerdown", mousemove: "pointermove" },
                                c = { mouseup: "MSPointerUp", mousedown: "MSPointerDown", mousemove: "MSPointerMove" };
                            t.navigator.pointerEnabled ? w[n](e, u[r], o) : t.navigator.msPointerEnabled ? w[n](e, c[r], o) : (w[n](e, i[r], o), w[n](e, r, o));
                        }
                        function i(e) {
                            if (void 0 !== e.touches) return e.touches.length;
                            if (void 0 !== e.which && 0 !== e.which) return e.which;
                            if (void 0 !== e.buttons) return e.buttons;
                            var n = e.button;
                            return void 0 !== n ? (1 & n ? 1 : 2 & n ? 3 : 4 & n ? 2 : 0) : void 0;
                        }
                        function u(e) {
                            var n = e.getBoundingClientRect();
                            return { left: n.left + c("scrollLeft", "pageXOffset"), top: n.top + c("scrollTop", "pageYOffset") };
                        }
                        function c(e, n) {
                            return "undefined" != typeof t[n] ? t[n] : S.clientHeight ? S[e] : x.body[e];
                        }
                        function a(e, n, t) {
                            var r,
                                o = e || {},
                                i = o.className;
                            return (o.className += " gu-hide"), (r = x.elementFromPoint(n, t)), (o.className = i), r;
                        }
                        function f() {
                            return !1;
                        }
                        function l() {
                            return !0;
                        }
                        function d(e) {
                            return e.width || e.right - e.left;
                        }
                        function s(e) {
                            return e.height || e.bottom - e.top;
                        }
                        function v(e) {
                            return e.parentNode === x ? null : e.parentNode;
                        }
                        function p(e) {
                            return "INPUT" === e.tagName || "TEXTAREA" === e.tagName || "SELECT" === e.tagName || m(e);
                        }
                        function m(e) {
                            return e ? ("false" === e.contentEditable ? !1 : "true" === e.contentEditable ? !0 : m(v(e))) : !1;
                        }
                        function g(e) {
                            function n() {
                                var n = e;
                                do n = n.nextSibling;
                                while (n && 1 !== n.nodeType);
                                return n;
                            }
                            return e.nextElementSibling || n();
                        }
                        function h(e) {
                            return e.targetTouches && e.targetTouches.length
                                ? e.targetTouches[0]
                                : e.changedTouches && e.changedTouches.length ? e.changedTouches[0] : e;
                        }
                        function y(e, n) {
                            var t = h(n),
                                r = { pageX: "clientX", pageY: "clientY" };
                            return e in r && !(e in t) && r[e] in t && (e = r[e]), t[e];
                        }
                        var b = e("contra/emitter"),
                            w = e("crossvent"),
                            E = e("./classes"),
                            x = document,
                            S = x.documentElement;
                        n.exports = r;
                    }.call(this, "undefined" != typeof global ? global : "undefined" != typeof self ? self : "undefined" != typeof window ? window : {}));
                },
                { "./classes": 1, "contra/emitter": 5, crossvent: 6 }
            ],
            3: [
                function(e, n, t) {
                    n.exports = function(e, n) {
                        return Array.prototype.slice.call(e, n);
                    };
                },
                {}
            ],
            4: [
                function(e, n, t) {
                    "use strict";
                    var r = e("ticky");
                    n.exports = function(e, n, t) {
                        e &&
                            r(function() {
                                e.apply(t || null, n || []);
                            });
                    };
                },
                { ticky: 9 }
            ],
            5: [
                function(e, n, t) {
                    "use strict";
                    var r = e("atoa"),
                        o = e("./debounce");
                    n.exports = function(e, n) {
                        var t = n || {},
                            i = {};
                        return (
                            void 0 === e && (e = {}),
                            (e.on = function(n, t) {
                                return i[n] ? i[n].push(t) : (i[n] = [t]), e;
                            }),
                            (e.once = function(n, t) {
                                return (t._once = !0), e.on(n, t), e;
                            }),
                            (e.off = function(n, t) {
                                var r = arguments.length;
                                if (1 === r) delete i[n];
                                else if (0 === r) i = {};
                                else {
                                    var o = i[n];
                                    if (!o) return e;
                                    o.splice(o.indexOf(t), 1);
                                }
                                return e;
                            }),
                            (e.emit = function() {
                                var n = r(arguments);
                                return e.emitterSnapshot(n.shift()).apply(this, n);
                            }),
                            (e.emitterSnapshot = function(n) {
                                var u = (i[n] || []).slice(0);
                                return function() {
                                    var i = r(arguments),
                                        c = this || e;
                                    if ("error" === n && t["throws"] !== !1 && !u.length) throw 1 === i.length ? i[0] : i;
                                    return (
                                        u.forEach(function(r) {
                                            t.async ? o(r, i, c) : r.apply(c, i), r._once && e.off(n, r);
                                        }),
                                        e
                                    );
                                };
                            }),
                            e
                        );
                    };
                },
                { "./debounce": 4, atoa: 3 }
            ],
            6: [
                function(e, n, t) {
                    (function(t) {
                        "use strict";
                        function r(e, n, t, r) {
                            return e.addEventListener(n, t, r);
                        }
                        function o(e, n, t) {
                            return e.attachEvent("on" + n, f(e, n, t));
                        }
                        function i(e, n, t, r) {
                            return e.removeEventListener(n, t, r);
                        }
                        function u(e, n, t) {
                            var r = l(e, n, t);
                            return r ? e.detachEvent("on" + n, r) : void 0;
                        }
                        function c(e, n, t) {
                            function r() {
                                var e;
                                return (
                                    p.createEvent ? ((e = p.createEvent("Event")), e.initEvent(n, !0, !0)) : p.createEventObject && (e = p.createEventObject()),
                                    e
                                );
                            }
                            function o() {
                                return new s(n, { detail: t });
                            }
                            var i = -1 === v.indexOf(n) ? o() : r();
                            e.dispatchEvent ? e.dispatchEvent(i) : e.fireEvent("on" + n, i);
                        }
                        function a(e, n, r) {
                            return function(n) {
                                var o = n || t.event;
                                (o.target = o.target || o.srcElement),
                                    (o.preventDefault =
                                        o.preventDefault ||
                                        function() {
                                            o.returnValue = !1;
                                        }),
                                    (o.stopPropagation =
                                        o.stopPropagation ||
                                        function() {
                                            o.cancelBubble = !0;
                                        }),
                                    (o.which = o.which || o.keyCode),
                                    r.call(e, o);
                            };
                        }
                        function f(e, n, t) {
                            var r = l(e, n, t) || a(e, n, t);
                            return h.push({ wrapper: r, element: e, type: n, fn: t }), r;
                        }
                        function l(e, n, t) {
                            var r = d(e, n, t);
                            if (r) {
                                var o = h[r].wrapper;
                                return h.splice(r, 1), o;
                            }
                        }
                        function d(e, n, t) {
                            var r, o;
                            for (r = 0; r < h.length; r++) if (((o = h[r]), o.element === e && o.type === n && o.fn === t)) return r;
                        }
                        var s = e("custom-event"),
                            v = e("./eventmap"),
                            p = t.document,
                            m = r,
                            g = i,
                            h = [];
                        t.addEventListener || ((m = o), (g = u)), (n.exports = { add: m, remove: g, fabricate: c });
                    }.call(this, "undefined" != typeof global ? global : "undefined" != typeof self ? self : "undefined" != typeof window ? window : {}));
                },
                { "./eventmap": 7, "custom-event": 8 }
            ],
            7: [
                function(e, n, t) {
                    (function(e) {
                        "use strict";
                        var t = [],
                            r = "",
                            o = /^on/;
                        for (r in e) o.test(r) && t.push(r.slice(2));
                        n.exports = t;
                    }.call(this, "undefined" != typeof global ? global : "undefined" != typeof self ? self : "undefined" != typeof window ? window : {}));
                },
                {}
            ],
            8: [
                function(e, n, t) {
                    (function(e) {
                        function t() {
                            try {
                                var e = new r("cat", { detail: { foo: "bar" } });
                                return "cat" === e.type && "bar" === e.detail.foo;
                            } catch (n) {}
                            return !1;
                        }
                        var r = e.CustomEvent;
                        n.exports = t()
                            ? r
                            : "function" == typeof document.createEvent
                              ? function(e, n) {
                                    var t = document.createEvent("CustomEvent");
                                    return n ? t.initCustomEvent(e, n.bubbles, n.cancelable, n.detail) : t.initCustomEvent(e, !1, !1, void 0), t;
                                }
                              : function(e, n) {
                                    var t = document.createEventObject();
                                    return (
                                        (t.type = e),
                                        n
                                            ? ((t.bubbles = Boolean(n.bubbles)), (t.cancelable = Boolean(n.cancelable)), (t.detail = n.detail))
                                            : ((t.bubbles = !1), (t.cancelable = !1), (t.detail = void 0)),
                                        t
                                    );
                                };
                    }.call(this, "undefined" != typeof global ? global : "undefined" != typeof self ? self : "undefined" != typeof window ? window : {}));
                },
                {}
            ],
            9: [
                function(e, n, t) {
                    var r,
                        o = "function" == typeof setImmediate;
                    (r = o
                        ? function(e) {
                              setImmediate(e);
                          }
                        : function(e) {
                              setTimeout(e, 0);
                          }),
                        (n.exports = r);
                },
                {}
            ]
        },
        {},
        [2]
    )(2);
});
