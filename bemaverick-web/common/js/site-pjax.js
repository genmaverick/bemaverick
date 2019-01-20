window.ST = window.ST || {};

window.ST.lib = window.ST.lib || {};
window.ST.lib.Site = function($, config) {
    this.config = null;
    this.isInitialized = false;
    this.isLoading = false;
    this.isUnloading = false;
    this.isMobile = false;
    this.isNativeApp = false;
    this.isIos = false;
    this.isAndroid = false;
    this.cancelBeforeUnload = false;
    this.googlePublisherConsole = false;
    this.hasFormDelegate = true;
    this.containers = null;
    this.controllers = {};
    this.timestamps = {};
    this.idCount = 0;
    this.detectedMobile = false;
    this.jqr = $;
    this.isClearingUnicorns = false;
    this.slots = {};
    this.nativePlatform = null;
    this.videoPlayers = {};
    var _resizeTimeout = null;
    var _scrollTimeout = null;
    var popupScrollTop = 0;
    var _refreshUnicornTimeout = null;
    var previousPageType = null;
    var previousPageSubType = null;
    var defaults = {
        httpHost: window.location.port
            ? window.location.protocol + "//" + window.location.hostname + ":" + window.location.port
            : window.location.protocol + "//" + window.location.hostname,
        packageBuildVersion: 0,
        scrollToSelector: "body",
        scrollToOffset: 65
    };

    var _testOnScreen = function(elem, offsets) {
        var win = $(window);
        var elem = $(elem);

        offsets = offsets ? offsets : { top: 0, left: 0, right: 0, bottom: 0 };
        var scrollTop = win.scrollTop();
        var scrollLeft = win.scrollLeft();
        var viewport = {
            top: scrollTop - offsets.top,
            left: scrollLeft - offsets.left
        };
        viewport.right = scrollLeft + win.width() + offsets.right;
        viewport.bottom = scrollTop + win.height() + offsets.bottom;
        var bounds = elem.offset();
        bounds.right = bounds.left + elem.outerWidth();
        bounds.bottom = bounds.top + elem.outerHeight();
        return !(viewport.right < bounds.left || viewport.left > bounds.right || viewport.bottom < bounds.top || viewport.top > bounds.bottom);
    };

    var _isOnScreen = function(offsets) {
        var elems = [];
        this.each(function() {
            if (_testOnScreen(this, offsets)) {
                elems.push(this);
            }
        });
        return $(elems);
    };

    var _init = function(config) {
        var $ = this.jqr;
        $.fn.isOnScreen = _isOnScreen;
        window.stjquery = $;
        History.Adapter.bind(window, "statechange", $.proxy(_handleHistory, this));
        this.config = $.extend({}, defaults, config.globals);
        this.controllers = config.controllers;
        this.containers = {
            main: config.containers.main,
            content: config.containers.content,
            nav: config.containers.nav,
            popup: config.containers.popup,
            errors: config.containers.errors
        };
        if (!window.console) {
            this.config.debugMode = false;
        }

        _detectScrollbarWidth();

        _createPopup.call(this, config.containers.popup);
        $(document).on("site:finishInit", $.proxy(_finishInit, this));
        $(document).on("site:triggerOptimize", $.proxy(_triggerOptimize, this));
        console.log("bind optimize");
        $(this.containers.main).on("click", "a:not(.ignore),.link", $.proxy(_handleClick, this));
        $(this.containers.main).on("submit", "form:not(.ignore)", $.proxy(_handleSubmit, this));
        $(window).on("resize", $.proxy(_handleResize, this));
        $(window).on("scroll", $.proxy(_handleScroll, this));
        if (this.config.trackingParams) {
            this.getTrackingParams = this.config.trackingParams;
        }

        var htmlClasses = [];
        if ($.browser.msie && $.browser.versionNumber > 9) {
            htmlClasses.push("ie ie" + $.browser.versionNumber + " lte" + $.browser.versionNumber);
        }
        if ($.browser.ipad || $.browser.ipod || $.browser.iphone) {
            htmlClasses.push("ios");
            this.isIos = true;
        }
        if ($.browser.android) {
            htmlClasses.push("android");
            this.isAndroid = true;
        }
        if ($.browser.mozilla) {
            htmlClasses.push("mozilla");
        }
        if ($.browser.mozilla) {
            htmlClasses.push("mozilla");
        }
        if ($("html").hasClass("mobile")) {
            this.isMobile = true;
        }
        htmlClasses.push("environment-" + this.config.environment);

        if ($.browser.mobile) {
            this.detectedMobile = true;
            htmlClasses.push("mobile-detected");
        } else {
            htmlClasses.push("not-mobile-detected");
        }
        if ($("html").hasClass("lte8")) {
            this.hasFormDelegate = false;
        }
        $("html").addClass(htmlClasses.join(" "));
        var locationHref = window.location.href;
        if (locationHref.indexOf("google_console") !== -1) {
            this.googlePublisherConsole = "google_console";
        } else if (locationHref.indexOf("google_force_console") !== -1) {
            this.googlePublisherConsole = "google_force_console";
        } else if (locationHref.indexOf("googfc") !== -1) {
            this.googlePublisherConsole = "googfc";
        }

        if (this.getQueryParamFromLocation("native_app") == "true") {
            this.isNativeApp = true;
        }

        _initModule.call(this, config.init);
        _handleResize.call(this);
        _handleScroll.call(this);
        _trackPage.call(this, config.init);

        var site = this;
        $(window).on("beforeunload", function(e) {
            if (!site.cancelBeforeUnload) {
                $(window).scrollTop(0);
                site.isUnloading = true;
            }
            site.cancelBeforeUnload = false;
        });
    };
    var _handleResize = function(e) {
        var $ = this.jqr;
        if (_resizeTimeout) {
            clearTimeout(_resizeTimeout);
            _resizeTimeout = null;
        }
        var delay = e ? 300 : 0;
        _resizeTimeout = setTimeout(function() {
            $.event.trigger("site:resize", e);
        }, delay);
    };

    var _handleScroll = function(e) {
        var $ = this.jqr;
        if (_scrollTimeout) {
            clearTimeout(_scrollTimeout);
            _scrollTimeout = null;
        }
        var delay = e ? 20 : 0;
        _scrollTimeout = setTimeout(function() {
            $.event.trigger("site:scroll", e);
        }, delay);
    };

    var _clearUnicorns = function(selector) {
        var $ = this.jqr;
        var elems = $(selector + " .unicorn.inited");
        this.isClearingUnicorns = true;
        var site = this;
        elems.each(function(index, elem) {
            elem = $(elem);
            var id = elem.attr("id");
            if (site.slots && site.slots[id] && window.googletag && window.googletag.destroySlots) {
                googletag.destroySlots([site.slots[id].slot]);
                site.slots[id] = undefined;
                try {
                    delete site.slots[id];
                } catch (e) {}
            }
        });
        this.isClearingUnicorns = false;
    };

    var _initializeForms = function() {
        if (!this.hasFormDelegate) {
            var forms = $(this.containers.content + " form:not(.form-initialized)");
            forms.on("submit", $.proxy(_handleSubmit, this));
            forms.addClass("form-initialized");
        }
    };
    var _createPopup = function(selector) {
        var $ = this.jqr;
        if (!$(selector).length) {
            $(this.containers.main).append('<div id="popup-mask"></div><div id="popup"></div>');
            $("#popup-mask").on("click", $.proxy(_handleHidePopup, this));
            $(selector).on("click", ".close", $.proxy(_handleHidePopup, this));
            if ($(this.containers.content).find(".popup-wrap")) {
                $("#popup").append($(this.containers.content).find(".popup-wrap"));
            }
            var self = this;
            $(selector).on("click", function(e) {
                if (e.currentTarget == e.target) {
                    _handleHidePopup.call(self, e);
                }
            });
        }
    };
    var _finishInit = function(e, obj) {
        var $ = this.jqr;
        var self = this;
        this.logTime("finishInit");
        this.refreshUnicorns(obj);
        var initTimeout = this.config.initTimeout ? this.config.initTimeout : 400;
        this.isInitialized = true;
        if (!obj.popup) {
            var module = obj.module ? obj.module : $(this.containers.content + " .type");
            if (module) {
                setTimeout(function() {
                    $(".transitioner").removeClass("added");
                    module.removeClass("not-inited");
                    setTimeout(function() {
                        $(".transitioner").remove();
                    }, 200);
                }, initTimeout);
            }
        } else {
            _showPopup.call(this);
        }
        this.loading = false;
        $(this.containers.main).removeClass("loading");
        $("html").addClass("site-inited");
        _updateTitle.call(this, obj);
        setTimeout(function() {
            _positionPage.call(self, obj);
        }, 64);
        if (obj.popupUrl) {
            this.dynamicRequest(obj.popupUrl);
        }
        setTimeout(function() {
            $.event.trigger("site:finishedInit", obj);
        }, initTimeout);
    };
    var _trackLink = function(elem) {
        var $ = this.jqr;
        if (this.config.debugMode) {
            console.log("_trackLink");
        }
        $.event.trigger("site:trackLink", elem);
    };
    var _trackPage = function(obj) {
        var $ = this.jqr;
        if (obj.pageTracking) {
            if (this.config.debugMode) {
                console.log("_trackPage");
            }
            setTimeout(function() {
                $.event.trigger("site:trackPage", obj);
            }, 0);
        }
    };
    var _updateTitle = function(obj) {
        if (obj.pageTitle && !obj.popup && !obj.isLive) {
            document.title = obj.pageTitle;
        }
    };
    var _positionPage = function(obj) {
        if (obj.noScroll || (obj.extraJs && obj.extraJs.galleryScrollTo)) {
            return;
        }

        var selector = null;
        var offset = null;
        if (!obj.popup && !obj.contentSelector && !obj.multiReplace) {
            selector = obj.scrollToSelector ? obj.scrollToSelector : this.config.scrollToSelector;
            offset = obj.scrollToOffset ? parseInt(obj.scrollToOffset) : this.config.scrollToOffset;
        } else if (obj.contentSelector) {
            offset = obj.scrollToOffset ? parseInt(obj.scrollToOffset) : this.config.scrollToOffset;
            if (obj.scrollToSelector == "INSERTPOINT" && obj.insertScrollTop) {
                this.scrollToPosition({
                    position: obj.insertScrollTop,
                    offset: offset
                });
                return;
            } else {
                selector = obj.scrollToSelector ? obj.scrollToSelector : obj.contentSelector;
            }
        }
        if (selector) {
            this.scrollToSelector({
                selector: selector,
                offset: offset
            });
        }
    };
    var _clearVideos = function(node) {
        if (typeof node === "string") {
            node = $(node);
        }
        var app = this;
        $.each(app.videoPlayers, function(key, value) {
            var player = $("#" + value.containerId);
            if (player.length && $.contains(node, player)) {
                if ($("html.lte9") && player.find("iframe").length) {
                    player.find("iframe").attr("src", "");
                }
                app.videoPlayers[key] = undefined;
                try {
                    delete app.videoPlayers[key];
                } catch (e) {}
            } else if (!player.length) {
                app.videoPlayers[key] = undefined;
                try {
                    delete app.videoPlayers[key];
                } catch (e) {}
            }
        });
    };

    var _showPopup = function() {
        var $ = this.jqr;
        var topOffset = window.scrollY;

        if (topOffset) {
            popupScrollTop = topOffset;
        } else if (popupScrollTop) {
            topOffset = popupScrollTop;
        }
        var self = this;
        setTimeout(function() {
            $("body")
                .addClass("popup-shown")
                .css({ top: -1 * topOffset + "px" });
            $(self.containers.popup + " .popup-bd")
                .attr("tabindex", -1)
                .focus();
        }, 100);
    };
    var _hidePopup = function(scrollToPosition) {
        var $ = this.jqr;
        if (!$(this.containers.popup).length) {
            return;
        }
        var self = this;
        setTimeout(function() {
            $("body")
                .removeClass("popup-shown")
                .css({ top: "" });
            $("body").removeClass("popup-non-scrollable");

            if (popupScrollTop && scrollToPosition) {
                self.scrollToPosition({
                    position: popupScrollTop,
                    duration: 1
                });
                popupScrollTop = 0;
            }
        }, 100);
        setTimeout(function() {
            $(self.containers.popup).empty();
        }, 400);
    };
    var _handleHidePopup = function(e) {
        var $ = this.jqr;
        e.preventDefault();
        var target = $(e.currentTarget);
        var container = $(this.containers.popup + " .popup-wrap");
        var self = this;
        if (container.length && container.attr("data-close-url") && !target.hasClass("no-close-url")) {
            var url = container.attr("data-close-url");
            this.dynamicRequest(url);
            setTimeout(function() {
                _trackLink.call(self, container);
            }, 0);
            return;
        }
        setTimeout(function() {
            _trackLink.call(self, container);
        }, 0);
        if ($(this.containers.content + " div.type.init-popup").length) {
            this.dynamicRequest("/");
        } else {
            _hidePopup.call(this, true);
        }
    };
    var _handleSubmit = function(e) {
        var $ = this.jqr;
        if (this.isLoading) {
            e.preventDefault();
            e.stopPropagation();
            return;
        }
        var target = $(e.currentTarget);
        if (target.hasClass("pass")) {
            return true;
        }
        if (target.attr("data-confirmMessage")) {
            var confirmed = confirm(target.attr("data-confirmMessage"));
            if (!confirmed) {
                e.preventDefault();
                e.stopPropagation();
                return false;
            }
        }
        var self = this;
        if (target.find(".btn[type=submit]").length) {
            var button = target.find(".btn[type=submit]");
            setTimeout(function() {
                _trackLink.call(self, button);
            }, 0);
        }
        var action = target.attr("action");
        if (action && (action.indexOf("http://") != -1 || action.indexOf("http://") != -1)) {
            if (action.indexOf(this.config.httpHost) === -1) {
                return true;
            }
        }

        var requestObj = {
            requestName: target.attr("data-request-name") ? target.attr("data-request-name") : "dynamicModule",
            noScroll: target.attr("data-no-scroll") ? target.data("no-scroll") : false,
            scrollToSelector: target.attr("data-scroll-to-selector") ? target.attr("data-scroll-to-selector") : false,
            scrollToOffset: target.attr("data-scroll-to-offset") ? target.attr("data-scroll-to-offset") : false,
            transitionType: target.attr("data-transition-type") ? target.attr("data-transition-type") : false
        };

        this.dynamicFormSubmit(target, requestObj);
        e.preventDefault();
    };
    var _handleClick = function(e) {
        var $ = this.jqr;
        if (this.isLoading) {
            e.preventDefault();
            e.stopPropagation();
            return;
        }
        var self = this;
        var target = $(e.currentTarget);
        var href = target.attr("data-href") ? target.attr("data-href") : e.currentTarget.href;
        if (href && href.indexOf("http://") === -1 && href.indexOf("https://") === -1 && href.indexOf("mailto:") === -1) {
            href = this.config.httpHost + href;
        } else {
            href = href;
        }

        if (target.closest(".link,a").length) {
            e.stopPropagation();
        }

        if (href.indexOf("mailto:") === 0 || href.indexOf(".pdf") == href.length - 4) {
            this.cancelBeforeUnload = true;
            return true;
        }

        if ((target.hasClass("link") || target.hasClass("fake-link")) && target.hasClass("ignore")) {
            window.location.href = href;
            return true;
        }

        if (target.hasClass("disabled")) {
            e.preventDefault();
            return;
        }

        // allow for control click
        if (href && e && (e.ctrlKey || e.metaKey)) {
            if (target.hasClass("link") || target.hasClass("fake-link")) {
                window.open(href);
            }
            return;
        }

        //fire link tracking if applicable - take out of process
        setTimeout(function() {
            _trackLink.call(self, target);
        }, 0);

        if (target.attr("data-window-options")) {
            window.open(href, "new_win", target.attr("data-window-options"));
            e.preventDefault();
            return;
        }

        //this is for link items with targets
        if (target.get(0).nodeName != "A" && target.attr("target") && href) {
            window.open(href, target.attr("target"));
            e.stopPropagation();
            return true;
        }

        if (target.get(0).nodeName == "A" && (target.attr("target") || target.hasClass("pass") || (href && href.indexOf(this.config.httpHost) === -1))) {
            if (target.data("append-redirect") && e.currentTarget.href) {
                e.currentTarget.href = this.appendRedirect(href);
            }
            if (href && href.indexOf(this.config.cookieDomain) === -1) {
                target.attr("target", "_blank");
                target.attr("rel", "noopener");
            }
            return true;
        }

        if (!href || href.indexOf("#") !== -1) {
            //todo: fix for non link href
            var hash = e.currentTarget.hash;
            if (hash && $('a[name="' + hash.replace("#", "") + '"]').length) {
                this.scrollToSelector({
                    selector: 'a[name="' + hash.replace("#", "") + '"]'
                });
                e.preventDefault();
            } else if (hash && hash == "#top") {
                this.scrollToSelector({
                    selector: "body"
                });
                e.preventDefault();
            }
            return;
        }

        var trackingParams = {};
        if (target.attr("data-tracking-params")) {
            trackingParams["gtm"] = this.getTrackingParams(target);
        }

        if (target.attr("data-click-event")) {
            $.event.trigger(target.attr("data-click-event"), target);
        }

        if (target.data("append-redirect")) {
            href = this.appendRedirect(href);
        }

        var requestObj = {
            requestName: target.attr("data-request-name") ? target.attr("data-request-name") : "dynamicModule",
            noHistory: target.attr("data-no-history") ? target.data("no-history") : false,
            noScroll: target.attr("data-no-scroll") ? target.data("no-scroll") : false,
            isSlide: target.attr("data-is-slide") ? target.data("is-slide") : false,
            scrollToSelector: target.attr("data-scroll-to-selector") ? target.attr("data-scroll-to-selector") : false,
            scrollToOffset: target.attr("data-scroll-to-offset") ? target.attr("data-scroll-to-offset") : false,
            transitionType: target.attr("data-transition-type") ? target.attr("data-transition-type") : false
        };

        if ($("html.lte9").length && requestObj.isSlide) {
            requestObj.isSlide = false;
            requestObj.requestName = "dynamicModule";
        }
        this.setLoading(true);
        this.dynamicRequest(href, requestObj, trackingParams);
        e.preventDefault();
    };
    var _handleHistory = function(e) {
        var $ = this.jqr;
        var state = History.getState();
        if (state.data.timestamp in this.timestamps) {
            // Deleting the unique timestamp associated with the state
            delete this.timestamps[state.data.timestamp];
        } else if (state.url) {
            this.dynamicRequest(state.url, {
                requestName: null,
                noHistory: true,
                noScroll: true,
                isSlide: false,
                isLive: false,
                isHistoryButton: true
            });
        }
    };

    var _handleLeanplumTrack = function(event, properties) {
        if (window) {
            Leanplum.track(event, properties);
        }
    };

    var _successAction = function(args, response, textStatus, jqXHR) {
        // put leanplum track events here
        if (response && response.subType) {
            // successful response post
            if (response.subType == "challenge-add-response-confirm") {
                _handleLeanplumTrack("WEB:POST_RESPONSE:SUCCESS");
            }
        }

        var $ = this.jqr;
        this.setLoading(false);
        if (response.redirectUrl) {
            var redirectUrl = response.redirectUrl;
            if (redirectUrl.indexOf(this.config.httpHost) === 0) {
                this.dynamicRequest(response.redirectUrl, args);
            } else {
                window.location.href = response.redirectUrl;
            }
            return;
        }

        if (response.packageBuildVersion && response.packageBuildVersion != this.config.packageBuildVersion && !args.isForm && !args.isLive) {
            var refreshUrl = args.url;
            if (args.noHistory) {
                var refreshUrl = History.getState() ? History.getState().url : window.location.href;
            } else if (response.browserHistoryUrl) {
                refreshUrl = response.browserHistoryUrl;
            }
            if (this.config.debugMode) {
                console.log("old code... refreshing");
            }
            if (refreshUrl) {
                refreshUrl = this.removeUriAttributes(refreshUrl, ["pbv"]);
                var delimiter = "&";
                if (refreshUrl.indexOf("?") == -1) {
                    delimiter = "?";
                }
                window.location.href = refreshUrl + delimiter + "pbv=" + response.packageBuildVersion;
                return;
            }
        }
        response.requestTime = args.requestTime;
        if (!response.error) {
            if (args.noScroll) {
                response.noScroll = args.noScroll;
            }
            if (args.noAds) {
                response.noAds = args.noAds;
            }
            if (args.extraParams) {
                response.extraParams = args.extraParams;
            }
            if (args.isSlide) {
                response.isSlide = args.isSlide;
            }
            if (args.unicornSelector) {
                response.unicornSelector = args.unicornSelector;
            }
            if (args.unicornClear) {
                response.unicornClear = args.unicornClear;
            }
            if (args.trackDelay) {
                response.trackDelay = args.trackDelay;
            }
            if (args.scrollToSelector) {
                response.scrollToSelector = args.scrollToSelector;
            }
            if (args.scrollToOffset) {
                response.scrollToOffset = args.scrollToOffset;
            }
            if (args.transitionType) {
                response.transitionType = args.transitionType;
            }
            response.args = args;
            response.isLive = args.isLive;

            _addToHistory.call(this, response, args);
            _initModule.call(this, response);
            _trackPage.call(this, response);
        } else {
            _initModule.call(this, response);
        }
    };
    var _successActionHandler = function(args) {
        return function(response, textStatus, jqXHR) {
            _successAction.call(this, args, response, textStatus, jqXHR);
        };
    };
    var _updatePageType = function(obj) {
        var $ = this.jqr;
        if (!obj.type || obj.type == previousPageType || obj.contentSelector || obj.popup || obj.isLive || obj.noReplace || obj.multiReplace) {
            if (this.config.debugMode) {
                console.log("no _updatePageType");
            }
            return;
        }
        if (previousPageType) {
            $("html").removeClass("page-type--not-index page-type--" + previousPageType);
        }
        previousPageType = obj.type;
        $("html").addClass("page-type--" + obj.type);
        if (obj.type != "index") {
            $("html").addClass("page-type--not-index");
        }
        $.event.trigger("site:changePageType");
    };
    var _updatePageSubType = function(obj) {
        var $ = this.jqr;
        if (!obj.subType || obj.contentSelector || obj.popup || obj.isLive || obj.noReplace || obj.multiReplace) {
            if (this.config.debugMode) {
                console.log("no _updatePageSubType");
            }
            return;
        }
        if (previousPageSubType) {
            $("html").removeClass("page-sub-type--" + previousPageSubType);
        }
        previousPageSubType = obj.subType;
        $("html").addClass("page-sub-type--" + obj.subType);
    };

    var _errorAction = function(args) {
        var $ = args.jqr;
        return function(jqXHR, textStatus, err) {
            if (jqXHR.status == 404 || jqXHR.status == 500) {
                _successAction.call(this, args, jqXHR.responseJSON, jqXHR.statusText, jqXHR);
                return;
            }
            this.setLoading(false);

            if (window.console && this.config.debugMode) {
                console.log(jqXHR.responseText);
            }
        };
    };

    var _detectScrollbarWidth = function() {
        var scrollDiv = document.createElement("div");
        scrollDiv.className = "scrollbar-measure";
        document.body.appendChild(scrollDiv);

        // Get the scrollbar width
        var scrollbarWidth = scrollDiv.offsetWidth - scrollDiv.clientWidth;
        document.body.removeChild(scrollDiv);
        var style = $("<style>.has-scrollbars .popup-hd { right: " + scrollbarWidth + "px; }</style>");
        $("html > head").append(style);
    };

    var _addToHistory = function(obj, args) {
        // _handleLeanplumAdvance();

        if ((args.noHistory && !args.isForm) || obj.popup || obj.noHistory) {
            return;
        }
        var url = args.url;
        if (obj.browserHistoryUrl) {
            url = obj.browserHistoryUrl;
        } else if (args.isForm) {
            return;
        }
        url = this.removeUriAttributes(url, ["pageType", "rnd", "more", "railPosition"]);
        var t = new Date().getTime();
        this.timestamps[t] = t;
        var pageTitle = obj.pageTitle ? obj.pageTitle : document.title;
        if (obj.historyReplace) {
            History.replaceState(
                {
                    timestamp: t
                },
                pageTitle,
                url
            );
        } else {
            History.pushState(
                {
                    timestamp: t
                },
                pageTitle,
                url
            );
        }
    };
    var _initModule = function(obj) {
        var $ = this.jqr;
        var curTime = new Date().getTime();
        var roundTripTime = curTime - obj.requestTime;

        if (obj.minRoundtripTime && roundTripTime < obj.minRoundtripTime) {
            var self = this;
            setTimeout(function() {
                _initModule.call(self, obj);
            }, obj.minRoundtripTime - roundTripTime);
            return;
        }
        var controllers = this.controllers;
        var type = obj.type;
        _updatePageType.call(this, obj);
        _updatePageSubType.call(this, obj);
        if (controllers["base"]) {
            controllers["base"](obj, this, $);
        }
        if (type && controllers[type]) {
            controllers[type](obj, this, $);
        } else if (type) {
            if (this.config.debugMode) {
                console.log('page type of "' + type + '" is not implemented using "default"');
            }
            controllers["default"](obj, this);
        }
    };
    this.dynamicFormSubmit = function(form, obj, $) {
        //todo
        if (!form) {
            return false;
        }
        // if the IO operation is in progress,
        // skip making another IO call.
        if (this.isLoading || this.isUnloading) {
            return false;
        }
        var requestTime = new Date().getTime();
        var requestName = form.attr("data-request-name") ? form.attr("data-request-name") : "dynamicModule";
        if (obj && obj.requestName) {
            requestName = obj.requestName;
        }
        var method = form.attr("method") ? form.attr("method") : "POST";
        var action = form.attr("action");
        var isPost = method.toLowerCase() == "post";
        var isForm = !isPost ? false : true;
        var noHistory = !isPost ? false : true;
        if (!isPost) {
            form.append('<input type="hidden" name="rnd" value="' + requestTime + '">');
        }
        if (this.isMobile) {
            form.append('<input type="hidden" name="mobile" value="1">');
        }
        if (this.isNativeApp) {
            form.append('<input type="hidden" name="native_app" value="true">');
        }

        obj = obj ? obj : {};
        obj.isForm = isForm;
        obj.noHistory = noHistory;
        obj.requestName = requestName;
        obj.requestTime = requestTime;
        if (!isPost) {
            var delimiter = action.indexOf("?") == -1 ? "?" : "&";
            obj.url = action + delimiter + form.serialize();
        }
        obj.jqr = this.jqr;
        this.setLoading(true);
        this.jqr.ajax({
            url: action,
            method: method.toUpperCase(),
            success: _successActionHandler(obj),
            error: _errorAction(obj),
            context: this,
            data: form.serializeArray(),
            dataType: "json",
            headers: {
                "Ajax-Request": requestName
            }
        });
    };
    this.dynamicRequest = function(url, obj, extraParams) {
        // if the IO operation is in progress,
        // skip making another IO call.
        if (this.isUnloading) {
            return false;
        }
        var $ = this.jqr;
        obj = obj ? obj : {};
        var requestTime = new Date().getTime();
        var requestName = obj.requestName ? obj.requestName : "dynamicModule";
        url = url.replace(this.config.httpHost, "");
        obj.url = url;
        obj.extraParams = $.isPlainObject(extraParams) ? extraParams : null;
        obj.isForm = false;
        var data = {
            rnd: requestTime,
            pbv: this.config.packageBuildVersion
        };
        if (obj.isSlide) {
            data.isSlide = obj.isSlide;
        }
        if (this.isMobile) {
            data.mobile = 1;
        }
        if (this.isNativeApp) {
            data.native_app = "true";
        }
        if (requestName != "dynamicModule") {
            data.requestName = requestName;
        }
        if (obj.isHistoryButton) {
            data.history = requestTime;
        }
        obj.requestTime = requestTime;
        obj.jqr = this.jqr;
        $.ajax({
            url: url,
            success: _successActionHandler(obj),
            error: _errorAction(obj),
            context: this,
            data: data,
            dataType: "json",
            headers: {
                "Ajax-Request": requestName
            }
        });
        if (!obj.isLive) {
            this.setLoading(true);
        }
    };
    this.insertContent = function(obj, eventName) {
        var $ = this.jqr;
        if (obj.content) {
            if (obj.contentSelector) {
                var destination = $(obj.contentSelector);
                if (destination.length) {
                    _clearVideos.call(this, obj.contentSelector);
                    _clearUnicorns.call(this, obj.contentSelector);
                    var newContent = $(obj.content);
                    var nodeName = newContent.get(0).nodeName;
                    var parentNode = destination.parent();
                    obj.insertScrollTop = destination.offset().top;
                    destination.replaceWith(newContent);
                    if (nodeName == "#document-fragment") {
                        obj.destination = parentNode;
                    } else {
                        obj.destination = newContent;
                    }
                    if (!obj.popup && !obj.isLive) {
                        _hidePopup.call(this);
                    }
                    if (obj.fullPageLike) {
                        $.event.trigger("site:fullPageLike", obj);
                    }
                } else {
                    if (this.config.debugMode) {
                        console.log("content selector " + obj.contentSelector + " not found: what to do?");
                    }
                    if (obj.browserHistoryUrl) {
                        History.replaceState(null, obj.pageTitle, obj.browserHistoryUrl);
                        window.location.reload();
                    }
                }
            } else if (obj.popup) {
                $(this.containers.popup)
                    .empty()
                    .html(obj.content);
                if (!this.hasFormDelegate) {
                    $(this.containers.popup + " form").on("submit", $.proxy(_handleSubmit, this));
                }
                obj.destination = this.containers.popup;
                $.event.trigger("site:popupPage", obj);
            } else if (!obj.noReplace) {
                _clearVideos.call(this, this.containers.content);
                _clearUnicorns.call(this, this.containers.content);
                var garbagedCleardOut = this.clearOutGarbage();

                if (obj.transitionType) {
                    $("body").append(
                        '<div class="transitioner added transitioner--' + obj.transitionType + '">' + $(this.containers.content + " .type").html() + "</div>"
                    );
                }
                $(this.containers.content)
                    .empty()
                    .html(obj.content + (obj.extraContent ? obj.extraContent : ""));
                if (obj.transitionType) {
                    $(this.containers.content + " .type").addClass("use-transition--" + obj.transitionType);
                }
                obj.destination = this.containers.content;
                _hidePopup.call(this);
                $.event.trigger("site:fullPage", obj);
            }
        } else if (obj.multiReplace) {
            // this is for replacing lots of thigns on the page, mostly for live status things
            $.each(obj.multiReplace, function(index, item) {
                if (item.selector && item.html) {
                    $(item.selector).replaceWith(item.html);
                }
            });
        } else {
            obj.destination = this.containers.content;
            $.event.trigger("site:fullPage", obj);
        }
        if (obj.type == "errors") {
            $("html").addClass("is-errors");
        } else {
            $("html").removeClass("is-errors");
        }

        var keepProcessing = true;
        if (obj.contentSelector || obj.popup || obj.isLive || obj.noReplace || obj.multiReplace || !this.config.optimizeFunctions) {
            if (this.config.debugMode) {
                console.log("no run optimize functions");
            }
        } else if (this.config.optimizeFunctions) {
            keepProcessing = _triggerOptimize.call(this);
        }

        if (!keepProcessing) {
            return;
        }

        _initializeForms.call(this);
        //fire callback after content is inserted
        $.event.trigger(eventName, obj);
        $.event.trigger("site:insert", obj);
    };
    _triggerOptimize = function() {
        var keepProcessing = true;
        if (this.config.optimizeFunctions) {
            for (var i = 0; i < this.config.optimizeFunctions.length; i++) {
                keepProcessing = this.config.optimizeFunctions[i]();
                if (!keepProcessing) {
                    return false;
                }
            }
        }
        return true;
    };
    this.removeUriAttributes = function(uri, attributes) {
        var $ = this.jqr;
        if (attributes && !$.isArray(attributes)) {
            attributes = [attributes];
        }
        attributes = attributes ? attributes : ["rnd"];
        toRemoveObject = {};
        for (var j = 0; j < attributes.length; j++) {
            toRemoveObject[attributes[j]] = true;
        }
        var pieces = uri.split("?");
        var pathName = pieces[0];
        var query = "";
        var newquery = query;
        var quest = "";
        if (pieces[1]) {
            query = pieces[1];
            if (query.indexOf("&") === 0) {
                query = query.substr(1);
            }
            var params = query.split("&");
            var nameValues = [];
            for (var i = 0; i < params.length; i++) {
                var tempNameValue = params[i].split("=");
                if (tempNameValue.length > 1 && !toRemoveObject[tempNameValue[0]]) {
                    nameValues.push(tempNameValue.join("="));
                }
            }
            newquery = nameValues.join("&");
        }
        if (newquery !== "") {
            quest = "?";
        }
        return pathName + quest + newquery;
    };
    this.getNextId = function() {
        var t = new Date().getTime();
        return "jq-" + t + "-" + this.idCount++;
    };
    this.generateId = function(elem) {
        elem = elem instanceof $ ? elem : $(elem);
        var id = elem.attr("id");
        if (!id) {
            id = this.getNextId();
            elem.attr("id", id);
        }
        return id;
    };
    this.refreshUnicorns = function(obj) {
        var $ = this.jqr;

        if (!obj || !obj.noAds) {
            if (_refreshUnicornTimeout) {
                clearTimeout(_refreshUnicornTimeout);
                _refreshUnicornTimeout = null;
            }

            var delay = obj.unicornDelay ? obj.unicornDelay : 0;
            _refreshUnicornTimeout = setTimeout(function() {
                $.event.trigger("unicorns:insert", obj);
            }, delay);
        }
    };
    this.clearOutGarbage = function() {
        if (window._ashq && window._ashq.destroy) {
            try {
                window._ashq.destroy();
            } catch (e) {
                console.log(e);
            }
            return true;
        }
        return false;
    };
    this.scrollToSelector = function(obj) {
        var $ = this.jqr;
        var elem = $(obj.selector);
        if (!elem.length) {
            return false;
        }
        var duration = obj.duration ? obj.duration : 150;
        var offset = obj.offset ? parseInt(obj.offset) : 0;
        var dest = elem.offset().top - offset;
        $("html, body").animate(
            {
                scrollTop: dest
            },
            {
                duration: duration,
                easing: "easeInSine",
                start: function() {
                    $("html").addClass("is-scrolling");
                },
                complete: function() {
                    setTimeout(function() {
                        $("html").removeClass("is-scrolling");
                    }, duration + 50);
                }
            }
        );
    };
    this.scrollToPosition = function(obj) {
        var $ = this.jqr;
        var duration = obj.duration ? obj.duration : 150;
        var offset = obj.offset ? parseInt(obj.offset) : 0;
        var dest = obj.position - offset;
        $("html, body").animate(
            {
                scrollTop: dest
            },
            {
                duration: duration,
                easing: "easeInSine",
                start: function() {
                    $("html").addClass("is-scrolling");
                },
                complete: function() {
                    setTimeout(function() {
                        $("html").removeClass("is-scrolling");
                    }, duration + 50);
                }
            }
        );
    };
    this.addToHistory = function(obj, args) {
        _addToHistory.call(this, obj, args);
    };
    this.clearVideos = function(node) {
        _clearVideos.call(this, node);
    };
    this.debounce = function(func, wait, immediate) {
        var timeout;
        return function() {
            var context = this,
                args = arguments;
            var later = function() {
                timeout = null;
                if (!immediate) func.apply(context, args);
            };
            var callNow = immediate && !timeout;
            clearTimeout(timeout);
            timeout = setTimeout(later, wait);
            if (callNow) func.apply(context, args);
        };
    };
    this.getTrackingParams = function() {
        return {};
    };
    this.logTime = function(msg) {
        if (!this.config.debugMode || !window.performance || !window.performance.timing) {
            return;
        }
        var now = new Date().getTime();
        var time = now - performance.timing.domLoading;
        if (msg) {
            console.log(msg, time);
        } else {
            console.log(time);
        }
    };
    this.getCookie = function(cname) {
        var name = cname + "=";
        var ca = document.cookie.split(";");
        for (var i = 0; i < ca.length; i++) {
            var c = ca[i];
            while (c.charAt(0) == " ") c = c.substring(1);
            if (c.indexOf(name) == 0) return c.substring(name.length, c.length);
        }

        return "";
    };

    this.getCookieAsJson = function(cname) {
        var cookie = this.getCookie(cname);
        if (!cookie) {
            return {};
        }
        var json = {};
        var chunks = decodeURIComponent(cookie).split("&");
        for (var i = 0; i < chunks.length; i++) {
            var chunk = chunks[i].split("=");
            json[chunk[0]] = chunk[1];
        }
        return json;
    };

    this.areCookiesEnabled = function() {
        var cookieEnabled = navigator.cookieEnabled ? true : false;
        if (typeof navigator.cookieEnabled == "undefined" && !cookieEnabled) {
            document.cookie = "testcookie";
            cookieEnabled = document.cookie.indexOf("testcookie") != -1 ? true : false;
        }
        return cookieEnabled;
    };
    this.getClassValue = function(elem, prefix) {
        node = elem instanceof $ ? elem : $(elem);
        var val = "";

        if (!node.length) {
            return val;
        }
        prefix = prefix + "-";
        var classNames = node.attr("class").split(" ");
        var len = classNames.length;
        for (var i = 0; i < len; i++) {
            var curClass = classNames[i];
            if (curClass.indexOf(prefix) != -1) {
                var nameVal = curClass.split(prefix);
                val = nameVal[1];
                break;
            }
        }
        return val;
    };
    this.trackLink = _trackLink;
    this.destroySlot = function(id) {
        if (this.slots && this.slots[id] && window.googletag && window.googletag.destroySlots) {
            googletag.destroySlots([this.slots[id].slot]);
            this.slots[id] = undefined;
            try {
                delete this.slots[id];
            } catch (e) {}
        }
    };
    this.setLoading = function(isLoading) {
        this.isLoading = isLoading;
        if (isLoading) {
            $(this.containers.main).addClass("loading");
        } else {
            $(this.containers.main).removeClass("loading");
        }
    };
    this.hasScrollBars = function(selector) {
        var $ = this.jqr;
        return $(selector).get(0).scrollHeight > $(selector).get(0).offsetHeight;
    };
    this.getQueryParamFromLocation = function(param, url) {
        url = url ? url : window.location.search;
        param = param.replace(/[\[]/, "\\[").replace(/[\]]/, "\\]");
        var regex = new RegExp("[\\?&]" + param + "=([^&#]*)");
        var results = regex.exec(url);
        return results === null ? "" : decodeURIComponent(results[1].replace(/\+/g, " "));
    };
    this.appendRedirect = function(href) {
        var delimiter = href.indexOf("?") == -1 ? "?" : "&";
        return href + delimiter + "redirect=" + encodeURIComponent(window.location.href);
    };
    this.successAction = function(args, response, textStatus, jqXHR) {
        _successAction.call(this, args, response, textStatus, jqXHR);
    };
    this.hidePopup = function() {
        _hidePopup.call(this);
    };
    this.handleClick = _handleClick;
    _init.call(this, config);
};
