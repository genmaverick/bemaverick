(function(t, e) {
    "object" == typeof exports && "undefined" != typeof module
        ? e(exports)
        : "function" == typeof define && define.amd ? define(["exports"], e) : e((t.RSVP = {}));
})(this, function(t) {
    "use strict";

    function e(t) {
        var e = t._promiseCallbacks;
        e || (e = t._promiseCallbacks = {});
        return e;
    }
    function r(t, e) {
        if (2 !== arguments.length) return dt[t];
        dt[t] = e;
    }
    function n() {
        setTimeout(function() {
            for (var t = 0; t < vt.length; t++) {
                var e = vt[t],
                    r = e.payload;
                r.guid = r.key + r.id;
                r.childGuid = r.key + r.childId;
                r.error && (r.stack = r.error.stack);
                dt.trigger(e.name, e.payload);
            }
            vt.length = 0;
        }, 50);
    }
    function o(t, e, r) {
        1 ===
            vt.push({
                name: t,
                payload: {
                    key: e._guidKey,
                    id: e._id,
                    eventName: t,
                    detail: e._result,
                    childId: r && r._id,
                    label: e._label,
                    timeStamp: Date.now(),
                    error: dt["instrument-with-stack"] ? new Error(e._label) : null
                }
            }) && n();
    }
    function i(t, e) {
        var r = this;
        if (t && "object" == typeof t && t.constructor === r) return t;
        var n = new r(c, e);
        _(n, t);
        return n;
    }
    function s() {
        return new TypeError("A promises callback cannot return that same promise.");
    }
    function u(t) {
        var e = typeof t;
        return null !== t && ("object" === e || "function" === e);
    }
    function c() {}
    function a(t) {
        try {
            return t.then;
        } catch (e) {
            gt.error = e;
            return gt;
        }
    }
    function f() {
        try {
            var t = jt;
            jt = null;
            return t.apply(this, arguments);
        } catch (e) {
            gt.error = e;
            return gt;
        }
    }
    function l(t) {
        jt = t;
        return f;
    }
    function h(t, e, r) {
        dt.async(function(t) {
            var n = !1,
                o = l(r).call(
                    e,
                    function(r) {
                        if (!n) {
                            n = !0;
                            e === r ? v(t, r) : _(t, r);
                        }
                    },
                    function(e) {
                        if (!n) {
                            n = !0;
                            m(t, e);
                        }
                    },
                    "Settle: " + (t._label || " unknown promise")
                );
            if (!n && o === gt) {
                n = !0;
                var i = gt.error;
                gt.error = null;
                m(t, i);
            }
        }, t);
    }
    function p(t, e) {
        if (e._state === bt) v(t, e._result);
        else if (e._state === wt) {
            e._onError = null;
            m(t, e._result);
        } else
            b(
                e,
                void 0,
                function(r) {
                    e === r ? v(t, r) : _(t, r);
                },
                function(e) {
                    return m(t, e);
                }
            );
    }
    function y(t, e, r) {
        var n = e.constructor === t.constructor && r === O && t.constructor.resolve === i;
        if (n) p(t, e);
        else if (r === gt) {
            var o = gt.error;
            gt.error = null;
            m(t, o);
        } else "function" == typeof r ? h(t, e, r) : v(t, e);
    }
    function _(t, e) {
        t === e ? v(t, e) : u(e) ? y(t, e, a(e)) : v(t, e);
    }
    function d(t) {
        t._onError && t._onError(t._result);
        w(t);
    }
    function v(t, e) {
        if (t._state === mt) {
            t._result = e;
            t._state = bt;
            0 === t._subscribers.length ? dt.instrument && o("fulfilled", t) : dt.async(w, t);
        }
    }
    function m(t, e) {
        if (t._state === mt) {
            t._state = wt;
            t._result = e;
            dt.async(d, t);
        }
    }
    function b(t, e, r, n) {
        var o = t._subscribers,
            i = o.length;
        t._onError = null;
        o[i] = e;
        o[i + bt] = r;
        o[i + wt] = n;
        0 === i && t._state && dt.async(w, t);
    }
    function w(t) {
        var e = t._subscribers,
            r = t._state;
        dt.instrument && o(r === bt ? "fulfilled" : "rejected", t);
        if (0 !== e.length) {
            for (var n = void 0, i = void 0, s = t._result, u = 0; u < e.length; u += 3) {
                n = e[u];
                i = e[u + r];
                n ? g(r, n, i, s) : i(s);
            }
            t._subscribers.length = 0;
        }
    }
    function g(t, e, r, n) {
        var o = "function" == typeof r,
            i = void 0;
        i = o ? l(r)(n) : n;
        if (e._state !== mt);
        else if (i === e) m(e, s());
        else if (i === gt) {
            var u = gt.error;
            gt.error = null;
            m(e, u);
        } else o ? _(e, i) : t === bt ? v(e, i) : t === wt && m(e, i);
    }
    function j(t, e) {
        var r = !1;
        try {
            e(
                function(e) {
                    if (!r) {
                        r = !0;
                        _(t, e);
                    }
                },
                function(e) {
                    if (!r) {
                        r = !0;
                        m(t, e);
                    }
                }
            );
        } catch (n) {
            m(t, n);
        }
    }
    function O(t, e, r) {
        var n = this,
            i = n._state;
        if ((i === bt && !t) || (i === wt && !e)) {
            dt.instrument && o("chained", n, n);
            return n;
        }
        n._onError = null;
        var s = new n.constructor(c, r),
            u = n._result;
        dt.instrument && o("chained", n, s);
        if (i === mt) b(n, s, t, e);
        else {
            var a = i === bt ? t : e;
            dt.async(function() {
                return g(i, s, a, u);
            });
        }
        return s;
    }
    function A(t, e, r) {
        this._remaining--;
        t === bt
            ? (this._result[e] = {
                  state: "fulfilled",
                  value: r
              })
            : (this._result[e] = {
                  state: "rejected",
                  reason: r
              });
    }
    function E(t, e) {
        return Array.isArray(t) ? new Ot(this, t, !0, e).promise : this.reject(new TypeError("Promise.all must be called with an array"), e);
    }
    function T(t, e) {
        var r = this,
            n = new r(c, e);
        if (!Array.isArray(t)) {
            m(n, new TypeError("Promise.race must be called with an array"));
            return n;
        }
        for (var o = 0; n._state === mt && o < t.length; o++)
            b(
                r.resolve(t[o]),
                void 0,
                function(t) {
                    return _(n, t);
                },
                function(t) {
                    return m(n, t);
                }
            );
        return n;
    }
    function P(t, e) {
        var r = this,
            n = new r(c, e);
        m(n, t);
        return n;
    }
    function S() {
        throw new TypeError("You must pass a resolver function as the first argument to the promise constructor");
    }
    function R() {
        throw new TypeError("Failed to construct 'Promise': Please use the 'new' operator, this object constructor cannot be called as a function.");
    }
    function x(t, e) {
        for (var r = {}, n = t.length, o = new Array(n), i = 0; i < n; i++) o[i] = t[i];
        for (var s = 0; s < e.length; s++) {
            var u = e[s];
            r[u] = o[s + 1];
        }
        return r;
    }
    function k(t) {
        for (var e = t.length, r = new Array(e - 1), n = 1; n < e; n++) r[n - 1] = t[n];
        return r;
    }
    function M(t, e) {
        return {
            then: function(r, n) {
                return t.call(e, r, n);
            }
        };
    }
    function C(t, e) {
        var r = function() {
            for (var r = arguments.length, n = new Array(r + 1), o = !1, i = 0; i < r; ++i) {
                var s = arguments[i];
                if (!o) {
                    o = N(s);
                    if (o === gt) {
                        var u = gt.error;
                        gt.error = null;
                        var a = new Tt(c);
                        m(a, u);
                        return a;
                    }
                    o && o !== !0 && (s = M(o, s));
                }
                n[i] = s;
            }
            var f = new Tt(c);
            n[r] = function(t, r) {
                t ? m(f, t) : void 0 === e ? _(f, r) : e === !0 ? _(f, k(arguments)) : Array.isArray(e) ? _(f, x(arguments, e)) : _(f, r);
            };
            return o ? I(f, n, t, this) : F(f, n, t, this);
        };
        r.__proto__ = t;
        return r;
    }
    function F(t, e, r, n) {
        var o = l(r).apply(n, e);
        if (o === gt) {
            var i = gt.error;
            gt.error = null;
            m(t, i);
        }
        return t;
    }
    function I(t, e, r, n) {
        return Tt.all(e).then(function(e) {
            return F(t, e, r, n);
        });
    }
    function N(t) {
        return null !== t && "object" == typeof t && (t.constructor === Tt || a(t));
    }
    function U(t, e) {
        return Tt.all(t, e);
    }
    function V(t, e) {
        if (!t) throw new ReferenceError("this hasn't been initialised - super() hasn't been called");
        return !e || ("object" != typeof e && "function" != typeof e) ? t : e;
    }
    function D(t, e) {
        if ("function" != typeof e && null !== e) throw new TypeError("Super expression must either be null or a function, not " + typeof e);
        t.prototype = Object.create(e && e.prototype, {
            constructor: {
                value: t,
                enumerable: !1,
                writable: !0,
                configurable: !0
            }
        });
        e && (Object.setPrototypeOf ? Object.setPrototypeOf(t, e) : (t.__proto__ = e));
    }
    function K(t, e) {
        return Array.isArray(t) ? new Pt(Tt, t, e).promise : Tt.reject(new TypeError("Promise.allSettled must be called with an array"), e);
    }
    function q(t, e) {
        return Tt.race(t, e);
    }
    function G(t, e) {
        if (!t) throw new ReferenceError("this hasn't been initialised - super() hasn't been called");
        return !e || ("object" != typeof e && "function" != typeof e) ? t : e;
    }
    function L(t, e) {
        if ("function" != typeof e && null !== e) throw new TypeError("Super expression must either be null or a function, not " + typeof e);
        t.prototype = Object.create(e && e.prototype, {
            constructor: {
                value: t,
                enumerable: !1,
                writable: !0,
                configurable: !0
            }
        });
        e && (Object.setPrototypeOf ? Object.setPrototypeOf(t, e) : (t.__proto__ = e));
    }
    function W(t, e) {
        return null === t || "object" != typeof t ? Tt.reject(new TypeError("Promise.hash must be called with an object"), e) : new Rt(Tt, t, e).promise;
    }
    function Y(t, e) {
        if (!t) throw new ReferenceError("this hasn't been initialised - super() hasn't been called");
        return !e || ("object" != typeof e && "function" != typeof e) ? t : e;
    }
    function $(t, e) {
        if ("function" != typeof e && null !== e) throw new TypeError("Super expression must either be null or a function, not " + typeof e);
        t.prototype = Object.create(e && e.prototype, {
            constructor: {
                value: t,
                enumerable: !1,
                writable: !0,
                configurable: !0
            }
        });
        e && (Object.setPrototypeOf ? Object.setPrototypeOf(t, e) : (t.__proto__ = e));
    }
    function z(t, e) {
        return null === t || "object" != typeof t
            ? Tt.reject(new TypeError("RSVP.hashSettled must be called with an object"), e)
            : new xt(Tt, t, !1, e).promise;
    }
    function B(t) {
        setTimeout(function() {
            throw t;
        });
        throw t;
    }
    function H(t) {
        var e = {
            resolve: void 0,
            reject: void 0
        };
        e.promise = new Tt(function(t, r) {
            e.resolve = t;
            e.reject = r;
        }, t);
        return e;
    }
    function J(t, e) {
        if (!t) throw new ReferenceError("this hasn't been initialised - super() hasn't been called");
        return !e || ("object" != typeof e && "function" != typeof e) ? t : e;
    }
    function Q(t, e) {
        if ("function" != typeof e && null !== e) throw new TypeError("Super expression must either be null or a function, not " + typeof e);
        t.prototype = Object.create(e && e.prototype, {
            constructor: {
                value: t,
                enumerable: !1,
                writable: !0,
                configurable: !0
            }
        });
        e && (Object.setPrototypeOf ? Object.setPrototypeOf(t, e) : (t.__proto__ = e));
    }
    function X(t, e, r) {
        return Array.isArray(t)
            ? "function" != typeof e ? Tt.reject(new TypeError("RSVP.map expects a function as a second argument"), r) : new kt(Tt, t, e, r).promise
            : Tt.reject(new TypeError("RSVP.map must be called with an array"), r);
    }
    function Z(t, e) {
        return Tt.resolve(t, e);
    }
    function tt(t, e) {
        return Tt.reject(t, e);
    }
    function et(t, e) {
        if (!t) throw new ReferenceError("this hasn't been initialised - super() hasn't been called");
        return !e || ("object" != typeof e && "function" != typeof e) ? t : e;
    }
    function rt(t, e) {
        if ("function" != typeof e && null !== e) throw new TypeError("Super expression must either be null or a function, not " + typeof e);
        t.prototype = Object.create(e && e.prototype, {
            constructor: {
                value: t,
                enumerable: !1,
                writable: !0,
                configurable: !0
            }
        });
        e && (Object.setPrototypeOf ? Object.setPrototypeOf(t, e) : (t.__proto__ = e));
    }
    function nt(t, e, r) {
        return "function" != typeof e
            ? Tt.reject(new TypeError("RSVP.filter expects function as a second argument"), r)
            : Tt.resolve(t, r).then(function(t) {
                  if (!Array.isArray(t)) throw new TypeError("RSVP.filter must be called with an array");
                  return new Ct(Tt, t, e, r).promise;
              });
    }
    function ot(t, e) {
        qt[Ft] = t;
        qt[Ft + 1] = e;
        Ft += 2;
        2 === Ft && Gt();
    }
    function it() {
        var t = process.nextTick,
            e = process.versions.node.match(/^(?:(\d+)\.)?(?:(\d+)\.)?(\*|\d+)$/);
        Array.isArray(e) && "0" === e[1] && "10" === e[2] && (t = setImmediate);
        return function() {
            return t(ft);
        };
    }
    function st() {
        return "undefined" != typeof It
            ? function() {
                  It(ft);
              }
            : at();
    }
    function ut() {
        var t = 0,
            e = new Vt(ft),
            r = document.createTextNode("");
        e.observe(r, {
            characterData: !0
        });
        return function() {
            return (r.data = t = ++t % 2);
        };
    }
    function ct() {
        var t = new MessageChannel();
        t.port1.onmessage = ft;
        return function() {
            return t.port2.postMessage(0);
        };
    }
    function at() {
        return function() {
            return setTimeout(ft, 1);
        };
    }
    function ft() {
        for (var t = 0; t < Ft; t += 2) {
            var e = qt[t],
                r = qt[t + 1];
            e(r);
            qt[t] = void 0;
            qt[t + 1] = void 0;
        }
        Ft = 0;
    }
    function lt() {
        try {
            var t = require,
                e = t("vertx");
            It = e.runOnLoop || e.runOnContext;
            return st();
        } catch (r) {
            return at();
        }
    }
    function ht(t, e, r) {
        e in t
            ? Object.defineProperty(t, e, {
                  value: r,
                  enumerable: !0,
                  configurable: !0,
                  writable: !0
              })
            : (t[e] = r);
        return t;
    }
    function pt() {
        dt.on.apply(dt, arguments);
    }
    function yt() {
        dt.off.apply(dt, arguments);
    }
    var _t = {
            mixin: function(t) {
                t.on = this.on;
                t.off = this.off;
                t.trigger = this.trigger;
                t._promiseCallbacks = void 0;
                return t;
            },
            on: function(t, r) {
                if ("function" != typeof r) throw new TypeError("Callback must be a function");
                var n = e(this),
                    o = void 0;
                o = n[t];
                o || (o = n[t] = []);
                o.indexOf(r) && o.push(r);
            },
            off: function(t, r) {
                var n = e(this),
                    o = void 0,
                    i = void 0;
                if (r) {
                    o = n[t];
                    i = o.indexOf(r);
                    i !== -1 && o.splice(i, 1);
                } else n[t] = [];
            },
            trigger: function(t, r, n) {
                var o = e(this),
                    i = void 0,
                    s = void 0;
                if ((i = o[t]))
                    for (var u = 0; u < i.length; u++) {
                        s = i[u];
                        s(r, n);
                    }
            }
        },
        dt = {
            instrument: !1
        };
    _t.mixin(dt);
    var vt = [],
        mt = void 0,
        bt = 1,
        wt = 2,
        gt = {
            error: null
        },
        jt = void 0,
        Ot = (function() {
            function t(t, e, r, n) {
                this._instanceConstructor = t;
                this.promise = new t(c, n);
                this._abortOnReject = r;
                this._isUsingOwnPromise = t === Tt;
                this._isUsingOwnResolve = t.resolve === i;
                this._init.apply(this, arguments);
            }
            t.prototype._init = function(t, e) {
                var r = e.length || 0;
                this.length = r;
                this._remaining = r;
                this._result = new Array(r);
                this._enumerate(e);
            };
            t.prototype._enumerate = function(t) {
                for (var e = this.length, r = this.promise, n = 0; r._state === mt && n < e; n++) this._eachEntry(t[n], n, !0);
                this._checkFullfillment();
            };
            t.prototype._checkFullfillment = function() {
                0 === this._remaining && v(this.promise, this._result);
            };
            t.prototype._settleMaybeThenable = function(t, e, r) {
                var n = this._instanceConstructor;
                if (this._isUsingOwnResolve) {
                    var o = a(t);
                    if (o === O && t._state !== mt) {
                        t._onError = null;
                        this._settledAt(t._state, e, t._result, r);
                    } else if ("function" != typeof o) this._settledAt(bt, e, t, r);
                    else if (this._isUsingOwnPromise) {
                        var i = new n(c);
                        y(i, t, o);
                        this._willSettleAt(i, e, r);
                    } else
                        this._willSettleAt(
                            new n(function(e) {
                                return e(t);
                            }),
                            e,
                            r
                        );
                } else this._willSettleAt(n.resolve(t), e, r);
            };
            t.prototype._eachEntry = function(t, e, r) {
                null !== t && "object" == typeof t ? this._settleMaybeThenable(t, e, r) : this._setResultAt(bt, e, t, r);
            };
            t.prototype._settledAt = function(t, e, r, n) {
                var o = this.promise;
                if (o._state === mt)
                    if (this._abortOnReject && t === wt) m(o, r);
                    else {
                        this._setResultAt(t, e, r, n);
                        this._checkFullfillment();
                    }
            };
            t.prototype._setResultAt = function(t, e, r, n) {
                this._remaining--;
                this._result[e] = r;
            };
            t.prototype._willSettleAt = function(t, e, r) {
                var n = this;
                b(
                    t,
                    void 0,
                    function(t) {
                        return n._settledAt(bt, e, t, r);
                    },
                    function(t) {
                        return n._settledAt(wt, e, t, r);
                    }
                );
            };
            return t;
        })(),
        At = "rsvp_" + Date.now() + "-",
        Et = 0,
        Tt = (function() {
            function t(e, r) {
                this._id = Et++;
                this._label = r;
                this._state = void 0;
                this._result = void 0;
                this._subscribers = [];
                dt.instrument && o("created", this);
                if (c !== e) {
                    "function" != typeof e && S();
                    this instanceof t ? j(this, e) : R();
                }
            }
            t.prototype._onError = function(t) {
                var e = this;
                dt.after(function() {
                    e._onError && dt.trigger("error", t, e._label);
                });
            };
            t.prototype["catch"] = function(t, e) {
                return this.then(void 0, t, e);
            };
            t.prototype["finally"] = function(t, e) {
                var r = this,
                    n = r.constructor;
                return r.then(
                    function(e) {
                        return n.resolve(t()).then(function() {
                            return e;
                        });
                    },
                    function(e) {
                        return n.resolve(t()).then(function() {
                            throw e;
                        });
                    },
                    e
                );
            };
            return t;
        })();
    Tt.all = E;
    Tt.race = T;
    Tt.resolve = i;
    Tt.reject = P;
    Tt.prototype._guidKey = At;
    Tt.prototype.then = O;
    var Pt = (function(t) {
        function e(e, r, n) {
            return V(this, t.call(this, e, r, !1, n));
        }
        D(e, t);
        return e;
    })(Ot);
    Pt.prototype._setResultAt = A;
    var St = Object.prototype.hasOwnProperty,
        Rt = (function(t) {
            function e(e, r) {
                var n = !(arguments.length > 2 && void 0 !== arguments[2]) || arguments[2],
                    o = arguments[3];
                return G(this, t.call(this, e, r, n, o));
            }
            L(e, t);
            e.prototype._init = function(t, e) {
                this._result = {};
                this._enumerate(e);
                0 === this._remaining && v(this.promise, this._result);
            };
            e.prototype._enumerate = function(t) {
                var e = this.promise,
                    r = [];
                for (var n in t)
                    St.call(t, n) &&
                        r.push({
                            position: n,
                            entry: t[n]
                        });
                var o = r.length;
                this._remaining = o;
                for (var i = void 0, s = 0; e._state === mt && s < o; s++) {
                    i = r[s];
                    this._eachEntry(i.entry, i.position);
                }
            };
            return e;
        })(Ot),
        xt = (function(t) {
            function e(e, r, n) {
                return Y(this, t.call(this, e, r, !1, n));
            }
            $(e, t);
            return e;
        })(Rt);
    xt.prototype._setResultAt = A;
    var kt = (function(t) {
            function e(e, r, n, o) {
                return J(this, t.call(this, e, r, !0, o, n));
            }
            Q(e, t);
            e.prototype._init = function(t, e, r, n, o) {
                var i = e.length || 0;
                this.length = i;
                this._remaining = i;
                this._result = new Array(i);
                this._mapFn = o;
                this._enumerate(e);
            };
            e.prototype._setResultAt = function(t, e, r, n) {
                if (n) {
                    var o = l(this._mapFn)(r, e);
                    o === gt ? this._settledAt(wt, e, o.error, !1) : this._eachEntry(o, e, !1);
                } else {
                    this._remaining--;
                    this._result[e] = r;
                }
            };
            return e;
        })(Ot),
        Mt = {},
        Ct = (function(t) {
            function e(e, r, n, o) {
                return et(this, t.call(this, e, r, !0, o, n));
            }
            rt(e, t);
            e.prototype._init = function(t, e, r, n, o) {
                var i = e.length || 0;
                this.length = i;
                this._remaining = i;
                this._result = new Array(i);
                this._filterFn = o;
                this._enumerate(e);
            };
            e.prototype._checkFullfillment = function() {
                if (0 === this._remaining) {
                    this._result = this._result.filter(function(t) {
                        return t !== Mt;
                    });
                    v(this.promise, this._result);
                }
            };
            e.prototype._setResultAt = function(t, e, r, n) {
                if (n) {
                    this._result[e] = r;
                    var o = l(this._filterFn)(r, e);
                    o === gt ? this._settledAt(wt, e, o.error, !1) : this._eachEntry(o, e, !1);
                } else {
                    this._remaining--;
                    r || (this._result[e] = Mt);
                }
            };
            return e;
        })(Ot),
        Ft = 0,
        It = void 0,
        Nt = "undefined" != typeof window ? window : void 0,
        Ut = Nt || {},
        Vt = Ut.MutationObserver || Ut.WebKitMutationObserver,
        Dt = "undefined" == typeof self && "undefined" != typeof process && "[object process]" === {}.toString.call(process),
        Kt = "undefined" != typeof Uint8ClampedArray && "undefined" != typeof importScripts && "undefined" != typeof MessageChannel,
        qt = new Array(1e3),
        Gt = void 0;
    Gt = Dt ? it() : Vt ? ut() : Kt ? ct() : void 0 === Nt && "function" == typeof require ? lt() : at();
    var Lt;
    dt.async = ot;
    dt.after = function(t) {
        return setTimeout(t, 0);
    };
    var Wt = function(t, e) {
        return dt.async(t, e);
    };
    if ("undefined" != typeof window && "object" == typeof window.__PROMISE_INSTRUMENTATION__) {
        var Yt = window.__PROMISE_INSTRUMENTATION__;
        r("instrument", !0);
        for (var $t in Yt) Yt.hasOwnProperty($t) && pt($t, Yt[$t]);
    }
    var zt = ((Lt = {
        asap: ot,
        Promise: Tt,
        EventTarget: _t,
        all: U,
        allSettled: K,
        race: q,
        hash: W,
        hashSettled: z,
        rethrow: B,
        defer: H,
        denodeify: C,
        configure: r,
        on: pt,
        off: yt,
        resolve: Z,
        reject: tt,
        map: X
    }),
    ht(Lt, "async", Wt),
    ht(Lt, "filter", nt),
    Lt);
    t["default"] = zt;
    t.asap = ot;
    t.Promise = Tt;
    t.EventTarget = _t;
    t.all = U;
    t.allSettled = K;
    t.race = q;
    t.hash = W;
    t.hashSettled = z;
    t.rethrow = B;
    t.defer = H;
    t.denodeify = C;
    t.configure = r;
    t.on = pt;
    t.off = yt;
    t.resolve = Z;
    t.reject = tt;
    t.map = X;
    t.async = Wt;
    t.filter = nt;
    Object.defineProperty(t, "__esModule", {
        value: !0
    });
});
