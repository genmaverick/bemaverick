window.ST = window.ST || {};
window.ST.lib = window.ST.lib || {};
window.ST.lib.Util = (function() {
    var site = null;
    var isInit = false;
    var $ = null;
    var touched = 2;
    var googleOptimizeTriggerCount = 0;

    var availableBreaks = [
        {
            media: "(min-width: 0px)",
            name: "phone",
            unicornType: "phone"
        },
        {
            media: "(min-width: 768px)",
            name: "tablet",
            unicornType: "tablet"
        },
        {
            media: "(min-width: 992px)",
            name: "desktop",
            unicornType: "desktop"
        },
        {
            media: "(min-width: 1200px)",
            name: "desktop-big",
            unicornType: "desktop"
        }
    ];
    var setBreak = null;

    var _handleChangeLayout = function(e, obj) {
        _changePageType(obj);
    };

    var _handleChangePageType = function(e) {
        if (!site.layout) {
            return;
        }
        _changePageType(site.layout);
    };

    var _changePageType = function(obj) {
        if (obj.previous && obj.current) {
            if (obj.current.name != "phone") {
                _hideResponsiveMenu();
            }
        }
    };

    var _handleResize = function(e) {
        var curBreak = null;
        if (!site.config.isFantasy) {
            for (var i = 0; i < availableBreaks.length; i++) {
                var thisBreak = availableBreaks[i];
                if (!curBreak || window.matchMedia(thisBreak.media).matches) {
                    curBreak = thisBreak;
                } else {
                    break;
                }
            }
        } else {
            if (site.isMobile) {
                curBreak = availableBreaks[0];
            } else {
                curBreak = availableBreaks[2];
            }
        }
        var previousBreak = setBreak ? $.extend({}, setBreak) : null;
        if (!setBreak || setBreak.name != curBreak.name) {
            setBreak = curBreak;
            $("html").removeClass("layout--phone layout--tablet layout--desktop layout--desktop-big");
            $("html").addClass("layout--" + curBreak.name);
            if (site.config.debugMode) {
                console.log(curBreak.name);
            }
            site.layout = curBreak;
            $.event.trigger("site:changeLayout", { current: curBreak, previous: previousBreak });
        }
        _updateFullWidthElements();
        _updateFullHeightElements();
        _sizeMediaComments();
    };

    var _updateFullWidthElements = function() {
        var winWidth = $(window).width();
        $(".full-width-element").each(function(index, elem) {
            elem = $(elem);
            var marginLeft = parseInt(elem.css("margin-left"));
            var marginRight = parseInt(elem.css("margin-right"));
            elemWidth = elem.width() + marginLeft + marginRight;
            var amountToDistribute = (elemWidth - winWidth) / 2;
            if (amountToDistribute > 0) {
                amountToDistribute = 0;
            }
            elem.css({
                "margin-left": Math.floor(amountToDistribute) + "px",
                "margin-right": Math.ceil(amountToDistribute) + "px"
            });

            elem.find(".page-width-element").css({
                "margin-left": Math.abs(Math.floor(amountToDistribute)) + "px",
                "margin-right": Math.abs(Math.ceil(amountToDistribute)) + "px"
            });
        });
        $(".break-left-element").each(function(index, elem) {
            elem = $(elem);
            var parent = elem.parent();
            var offset = parent.offset();
            var left = offset.left < 0 ? 0 : offset.left;
            elem.css({
                "margin-left": -1 * left + "px"
            });
        });
    };

    var _updateFullHeightElements = function() {
        var winHeight = $(window).height();
        $(".full-height-element").css({ height: winHeight + "px" });
    };

    var _triggerGoogleOptimize = function() {
        if (window.dataLayer && window.dataLayer.push && googleOptimizeTriggerCount) {
            window.dataLayer.push({ event: "optimize.activate" });
            if (site.config.debugMode) {
                console.log("t g o", googleOptimizeTriggerCount);
            }
        }
        googleOptimizeTriggerCount++;
    };

    var facebookInitCalled = false;
    var _initializeFacebook = function() {
        if (facebookInitCalled) {
            return;
        }

        FB.init({
            appId: site.config.facebookAppId,
            status: false,
            cookie: false,
            xfbml: false,
            version: "v2.7"
        });

        facebookInitCalled = true;
    };

    var _getIframeFromMessageEvent = function(e) {
        var iframes = document.getElementsByTagName("iframe");
        var iframe;
        for (var i = iframes.length - 1; i >= 0; i--) {
            var curFrame = iframes[i];
            if (curFrame.contentWindow === e.source) {
                iframe = curFrame;
                break;
            }
        }
        return iframe;
    };

    var _handleMessage = function(e) {
        var message = e.originalEvent;
        if (!message || !message.data) {
            return;
        }
        var iframe = _getIframeFromMessageEvent(message);
        if (message.origin.indexOf("brackify.com") != -1) {
            var iframeWrap = $("#brackify-iframe-wrap");
            if (iframeWrap.length) {
                if (message.data == "scroll") {
                    site.scrollToSelector({
                        selector: "#brackify-iframe-wrap"
                    });
                } else if (parseInt(message.data)) {
                    iframeWrap.setStyle("height", parseInt(message.data) + "px");
                }
            }
        } else if (message.data.indexOf && message.data.indexOf("{") === 0) {
            try {
                messageObj = $.parseJSON(message.data);
                $.event.trigger("site:message", { data: messageObj, origin: message.origin, iframe: iframe });
            } catch (e) {
                console.log("JSON Parse failed!!");
            }
        } else {
            $.event.trigger("site:message", { data: message.data, origin: message.origin });
        }
    };

    var addedScripts = {};
    var _initExtraJs = function(e, obj) {
        if (obj.extraJs) {
            $.each(obj.extraJs, function(index, js) {
                if (!addedScripts[js.url] || js.reload) {
                    addedScripts[js.url] = true;
                    window.externalJQ = $;
                    $.getCachedScript(js.url).done(function(script, textStatus) {
                        if (js.js) {
                            eval(js.js);
                        }
                    });
                } else if (js.js) {
                    eval(js.js);
                }
            });
        }
    };

    var _substringMatcher = function(strs) {
        return function findMatches(q, cb) {
            var matches, substringRegex;

            // an array that will be populated with substring matches
            matches = [];

            // regex used to determine if a string contains the substring `q`
            substrRegex = new RegExp(q, "i");

            // iterate through the pool of strings and for any string that
            // contains the substring `q`, add it to the `matches` array
            $.each(strs, function(i, str) {
                if (substrRegex.test(str.title)) {
                    matches.push(str);
                }
            });
            cb(matches);
        };
    };

    var _clearedMessages = false;
    var _initCachedMessages = function() {
        if (_clearedMessages) {
            return;
        }
        _clearedMessages = true;
        if (window._cachedMessages && window._cachedMessages.length) {
            for (var i = 0; i < window._cachedMessages.length; i++) {
                _handleMessage(window._cachedMessages[i]);
            }
            window._cachedMessages = undefined;
        }
    };

    var _handleTrackPixel = function(e, elem) {
        var node = elem instanceof $ ? elem : $(elem);
        var trackingUrl = node.attr("data-click-pixel-url");
        if (trackingUrl) {
            $('<img src="' + trackingUrl.replace("[TIMESTAMP]", new Date().getTime()) + '">').imagesLoaded(function() {
                if (site.config.debugMode) {
                    console.log("click pixel loaded", trackingUrl);
                }
            });
        }
    };
    var _loadPixels = function() {
        $(".post-pixel:not(.inited)").each(function(index, elem) {
            elem = $(elem);
            var trackingUrl = elem.attr("data-img-src");
            if (trackingUrl) {
                $('<img src="' + trackingUrl.replace("[TIMESTAMP]", new Date().getTime()) + '">').imagesLoaded(function() {
                    if (site.config.debugMode) {
                        console.log("view pixel loaded", trackingUrl);
                    }
                });
            }
            elem.addClass("inited");
        });
    };

    var _handleUpdateInputs = function(e) {
        _initFormItems();
    };

    var _initFormItems = function() {
        $(site.containers.content + " .formItems .control-group").each(function(index, container) {
            container = $(container);
            var inputs = container.find(".controls .form-control");
            if (inputs.length) {
                var input = $(inputs[0]);
                if (input.val() == "") {
                    container.addClass("empty");
                } else {
                    container.removeClass("empty");
                }
                if (input.is(":focus")) {
                    container.addClass("active");
                } else {
                    container.removeClass("active");
                }
            }
        });
    };

    var _handleMenuClick = function(e) {
        $("html").toggleClass("show-responsive-menu");
    };

    var _hideResponsiveMenu = function() {
        $("html").removeClass("show-responsive-menu");
    };

    var _handleClickHover = function(e) {
        var add = true;
        if ($(e.currentTarget).hasClass("click-hover")) {
            add = false;
        }
        $(".click-hover").removeClass("click-hover");
        if (add) {
            $(e.currentTarget).addClass("click-hover");
        }
    };

    var _initGradients = function() {
        $("div[data-maverick-level]:not(.inited-maverick-level)").each(function(index, item) {
            item = $(item);
            var stops = item.attr("data-maverick-level");
            var gradient = new ConicGradient({
                stops: stops,
                size: 200
            });
            item.css("background-image", "url(" + gradient.png + ")");
            item.addClass("inited-maverick-level");
        });
    };

    var _sizeMediaComments = function() {
        var layoutType = site.layout.name;
        var mediaModules = $(".media-module");
        mediaModules.each(function(index, module) {
            module = $(module);
            media = module.find(".media-wrap");
            var maxHeight = "none";
            if (layoutType != "phone") {
                var width = media.width();
                maxHeight = width / 3 * 4;
                var difference = 0;
                difference += module.find(".media-text__status").outerHeight();
                difference += module.find(".comments__form").outerHeight();
                module.find(".comments").css({ height: maxHeight - difference + "px" });
            } else {
                module.find(".comments").css({ height: "auto" });
            }
            module.find(".media-text").css({ "max-height": maxHeight + "px" });
        });
    };

    var _triggerTransitions = function() {
        $(".trigger-transition").removeClass("trigger-transition");
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
                console.log("Util.init");
            }
            //things to do
            $(document).on("site:resize css:loaded", _handleResize);
            $(document).on("site:changeLayout", _handleChangeLayout);
            $(document).on("site:changePageType", _handleChangePageType);
            $(document).on("site:insert", _initExtraJs);
            $(document).on("site:insert", _initCachedMessages);
            $(document).on("site:insert", _updateFullWidthElements);
            $(document).on("site:insert", _updateFullHeightElements);
            $(document).on("site:insert", _loadPixels);
            $(document).on("site:insert", _initFormItems);
            $(document).on("site:insert", _hideResponsiveMenu);
            $(document).on("site:insert", _sizeMediaComments);
            $(document).on("site:trackLink", _handleTrackPixel);
            $(document).on("site:insert", _initGradients);
            $(document).on("site:insert", _triggerTransitions);

            $(document).on("site:fullPage site:popupPage", _triggerGoogleOptimize);
            $(window).on("message", _handleMessage);

            $(document).on("site:insert", function() {
                $(site.containers.main + " .click-hover").removeClass("click-hover");
            });

            $(site.containers.main).on("click", ".custom-hover-click", _handleClickHover);
            $(site.containers.main).on("click", ".toggle-responsive-menu", _handleMenuClick);

            $(site.containers.content).on("change focus blur", ".formItems .control-group .controls .form-control", _handleUpdateInputs);

            _handleResize();

            if ($.browser.msie && !$.browser.edge) {
                $("body").on("mousewheel", function() {
                    // remove default behavior
                    event.preventDefault();
                    //scroll without smoothing
                    var wheelDelta = event.wheelDelta;
                    var currentScrollPosition = window.pageYOffset;
                    window.scrollTo(0, currentScrollPosition - wheelDelta);
                });
            }
        },
        initializeFacebook: _initializeFacebook
    };
})();
