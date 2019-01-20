window.ST = window.ST || {};
window.ST.lib = window.ST.lib || {};
window.ST.lib.PageTracking = (function() {
    var site = null;
    var isInit = false;
    var loaded = false;
    var $ = null;
    var dataLayerByEvent = window.dataLayerByEvent ? window.dataLayerByEvent : {};
    var previousPageUrl = "";
    var delayedEvent = null;
    var handleTrackPage = function(e, obj) {
        var providers = obj && obj.pageTracking && obj.pageTracking.providers ? obj.pageTracking.providers : null;
        if (!providers) {
            return;
        }
        $.each(providers, function(key, value) {
            if (key == "gtm") {
                trackPageGTM(value, obj.extraParams, obj);
            }
        });
    };

    var _getGender = function(obj) {
        var gender = obj && obj["g"] ? obj["g"] : null;
        if (gender && gender == "M") {
            gender = "male";
        } else if (gender) {
            gender = "female";
        }
        return gender;
    };

    var trackPageGTM = function(data, extraParams, obj) {
        var events = data.events;

        var auCookie = site.getCookieAsJson("au");
        if (!events) {
            return;
        }
        var isInitial = obj && obj.pageTracking && obj.pageTracking.isInitial ? true : false;

        if (!window.dataLayer) {
            window.dataLayer = [];
        }
        if (!isInitial || site.isNativeApp) {
            for (var i = 0; i < events.length; i++) {
                var curEvent = events[i];
                var eventName = curEvent.event;
                curEvent = $.extend({}, { event: eventName }, curEvent.site, userInfo, curEvent.page);

                if (eventName == "dataLayer-initialized") {
                    eventName = "global-virtual-pageview";
                    curEvent = clearOutObject(curEvent, curEvent);
                    dataLayerByEvent[eventName] = curEvent;
                }

                if (dataLayerByEvent[eventName]) {
                    curEvent = clearOutObject(dataLayerByEvent[eventName], curEvent);
                }
                dataLayerByEvent[eventName] = curEvent;
                if (curEvent.event && site.config.debugMode) {
                    console.log(curEvent);
                }
                window.dataLayer.push(curEvent);

                trackNative(eventName, curEvent);
            }
        }
        if (!loaded && site.config.gtmId) {
            (function(w, d, s, l, i) {
                w[l] = w[l] || [];
                w[l].push({
                    "gtm.start": new Date().getTime(),
                    event: "gtm.js"
                });
                var f = d.getElementsByTagName(s)[0],
                    j = d.createElement(s),
                    dl = l != "dataLayer" ? "&l=" + l : "";
                j.async = true;
                j.src = "https://www.googletagmanager.com/gtm.js?id=" + i + dl;
                f.parentNode.insertBefore(j, f);
            })(window, document, "script", "dataLayer", site.config.gtmId);
            loaded = true;
        }
    };

    var toCamelCase = function(text) {
        return (camelCased = text.replace(/-([a-z])/g, function(g) {
            return g[1].toUpperCase();
        }));
    };

    var trackNative = function(eventName, data) {
        if (site.isNativeApp) {
            delete data.event;
            delete data["user-notifications"];
            var newData = {};
            $.each(data, function(key, value) {
                if (value) {
                    newData[key] = value;
                }
            });
            eventName = eventName == "global-virtual-pageview" ? "screen-load" : eventName;
            if (window.wslAndroidAnalytics && window.wslAndroidAnalytics.trackEvent) {
                window.wslAndroidAnalytics.trackEvent(eventName, JSON.stringify(newData));
            } else if (site.isIos) {
                newData.event = eventName;
                var keyValuePairs = Object.keys(newData)
                    .map(function(key) {
                        return encodeURIComponent(key) + "=" + encodeURIComponent(newData[key]);
                    })
                    .join("&");

                window.location.href = "wsl://analytics?" + keyValuePairs;
            } else {
                newData.event = eventName;
                if (site.config.debugMode) {
                    console.log(newData);
                }
            }
        }
    };

    var clearOutObject = function(previous, current) {
        if (!previous) {
            return current;
        }
        $.each(previous, function(key, value) {
            if (typeof current[key] === "undefined" || current[key] === "undefined") {
                current[key] = undefined;
            } else if ($.isPlainObject(current[key])) {
                current[key] = clearOutObject(value, current[key]);
            } else if (!current[key] && !$.isNumeric(current[key])) {
                current[key] = undefined;
            }
        });
        return current;
    };

    var handleTrackLink = function(e, elem) {
        var node = elem instanceof $ ? elem : $(elem);
        if (!node.length) {
            return;
        }
        var gtmEvent = node.attr("data-gtm-event");
        if (!gtmEvent) {
            return;
        }
        var gtmObject = null;
        try {
            gtmObject = JSON.parse(gtmEvent);
            window.dataLayer.push(gtmObject);
            trackNative(gtmObject.event, gtmObject);
        } catch (e) {
            console.log("ERRR");
        }
    };

    var handleTrackEvent = function(e, gtmObject) {
        if (window.dataLayer && window.dataLayer.push) {
            window.dataLayer.push(gtmObject);
            trackNative(gtmObject.event, gtmObject);
        }
    };

    return {
        init: function(initSite, jquery) {
            if (isInit) {
                return;
            }
            isInit = true;
            $ = jquery;
            site = initSite;
            if (site.config.debugMode) {
                console.log("PageTracking.init");
            }
            environment = site.config.unicornsEnvironment;
            $(document).on("site:trackLink", handleTrackLink);
            $(document).on("site:trackEvent", handleTrackEvent);
            $(document).on("site:trackPage", function(e, obj) {
                if (delayedEvent) {
                    clearTimeout(delayedEvent);
                    delayedEvent = null;
                }
                if (obj.trackDelay) {
                    delayedEvent = setTimeout(function() {
                        handleTrackPage(e, obj);
                    }, obj.trackDelay);
                } else {
                    handleTrackPage(e, obj);
                }
            });
        }
    };
})();
