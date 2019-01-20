window.ST = window.ST || {};
window.ST.lib = window.ST.lib || {};
window.ST.lib.Carousels = (function() {
    var site = null;
    var isInit = false;
    var $ = null;
    var slideSettleTimeout = null;
    var flickityResizeTimeout = null;

    var _handleInsert = function(e, obj) {
        _initCarousels(e, obj);
        _initScrollNavs(e, obj);
        _initHorizontalScrollers(e, obj);
    };

    var _initScrollNavs = function(e, obj) {
        var items = $(".scroll-nav:not(.inited)");
        if (!items.length) {
            return;
        }

        items.each(function(index, nav) {
            nav = $(nav);
            var id = site.generateId(nav);
            var wrap = nav.find(".scroll-nav-wrap");
            var width = wrap.width();
            var scrollWidth = wrap[0].scrollWidth;
            var selected = nav.find(".scroll-nav-item.selected");
            var cellAlign = nav.attr("data-cell-align") ? nav.attr("data-cell-align") : scrollWidth > width ? "center" : "left";
            var prevNextButtons = nav.attr("data-prev-next-buttons") ? true : false;
            var type = nav.attr("data-type");
            var freeScroll = true;
            var groupCells = false;
            var initialIndex = 0;
            if (selected.length) {
                initialIndex = parseInt(selected.attr("data-item-index"));
            }
            nav.addClass("inited");
            if (index) {
            }
            wrap.find("a.ignore").addClass("really-ignore");
            wrap.find("a:not(.pass)").addClass("ignore");
            var numItems = wrap.find(".carousel-item").length;

            if (type == "event-strip") {
                freeScroll = false;
                groupCells = true;
            }

            var config = {
                cellAlign: cellAlign,
                contain: true,
                pageDots: false,
                cellSelector: ".scroll-nav-item",
                initialIndex: initialIndex,
                adaptiveHeight: false,
                prevNextButtons: prevNextButtons,
                wrapAround: false,
                freeScroll: freeScroll,
                groupCells: groupCells
            };

            var flickityCarousel = wrap.flickity(config);
            flickityCarousel.on("staticClick.flickity", function(event, pointer, cellElement, cellIndex) {
                if (!cellElement) {
                    return;
                }
                var link = $(cellElement).find("a");
                if (link.length && !link.hasClass("really-ignore") && !link.hasClass("pass")) {
                    var href = link.attr("href");
                    if (href && href.indexOf("http") === 0 && href.indexOf(site.config.httpHost) === -1) {
                        if (href.indexOf(site.config.cookieDomain) === -1) {
                            window.open(href);
                        } else {
                            window.location.href = href;
                        }
                        $.event.trigger("site:trackLink", link);
                        return true;
                    }
                    site.dynamicRequest(href, {
                        requestName: link.attr("data-request-name"),
                        noScroll: link.data("no-scroll"),
                        noHistory: link.data("no-history"),
                        isSlide: link.data("is-slide")
                    });
                    if (link.attr("data-request-name")) {
                        link.closest("ul").find(".selected").removeClass("selected");
                        link.closest("li").addClass("selected");
                        flickityCarousel.flickity("select", cellIndex);
                    }
                    if (link.attr("data-click-event")) {
                        $.event.trigger(link.attr("data-click-event"), link);
                    }
                    site.trackLink(link);
                } else if (nav.attr("data-select-on-click")) {
                    var ce = $(cellElement);
                    ce.closest(".scroll-nav-wrap").find(".selected").removeClass("selected");
                    ce.addClass("selected");
                    flickityCarousel.flickity("select", cellIndex);
                    if (nav.attr("data-event-select")) {
                        $.event.trigger(nav.attr("data-event-select"), { index: cellIndex, nav: nav });
                    }
                }
            });
            if (nav.attr("data-add-indicator")) {
                flickityCarousel.find(".flickity-slider").append('<div class="scroll-nav-indicator"></div>');
            }
            if (nav.attr("data-event-select")) {
                $.event.trigger(nav.attr("data-event-select"), { index: initialIndex, nav: nav });
            }

            setTimeout(function() {
                flickityCarousel.flickity("resize");
            }, 100);
        });
    };

    var _initCarousels = function() {
        if ($("html.lte9").length) {
            return;
        }
        var items = $(".carousel:not(.inited)");
        if (!items.length) {
            return;
        }
        items.each(function(index, carousel) {
            carousel = $(carousel);
            var id = site.generateId(carousel);
            var wrap = carousel.find(".carousel-wrap");
            var adaptiveHeight = carousel.attr("data-adaptive-height") === "false" ? false : true;
            var wrapAround = carousel.attr("data-wrap-around") === "true" ? true : false;
            var prevNextButtons = carousel.attr("data-prev-next-buttons") === "false" ? false : true;
            var selected = carousel.find(".carousel-item.is-selected");
            var initialIndex = selected ? parseInt(selected.attr("data-item-index")) : 0;
            carousel.addClass("inited");
            var numItems = wrap.find(".carousel-item").length;
            var config = {
                adaptiveHeight: adaptiveHeight,
                arrowShape: {
                    x0: 10,
                    x1: 60,
                    y1: 50,
                    x2: 60,
                    y2: 40,
                    x3: 20
                },
                cellAlign: "left",
                cellSelector: ".carousel-item",
                contain: true,
                friction: 0.8,
                initialIndex: initialIndex,
                pageDots: false,
                prevNextButtons: prevNextButtons,
                selectedAttraction: 0.2,
                wrapAround: wrapAround
            };
            if (numItems < 2) {
                config.prevNextButtons = false;
                config.draggable = false;
            }

            if (carousel.attr("data-wrap-around") === "true") {
                config.wrapAround = true;
            }
            if (carousel.attr("data-cell-align")) {
                config.cellAlign = carousel.attr("data-cell-align");
            }
            if (carousel.attr("data-contain") === "false") {
                config.contain = false;
            }
            var flickityCarousel = wrap.flickity(config);
            flickityCarousel.on("select.flickity", function(e) {
                var data = $(this).data("flickity");
                var item = $(data.selectedElement);

                var transitionClasses = item.attr("data-transition-classes");
                var previousSelectedIndex = carousel.attr("data-selected-index") ? carousel.attr("data-selected-index") : "";
                var isSame = previousSelectedIndex.length && parseInt(previousSelectedIndex) == data.selectedIndex;
                if (transitionClasses) {
                    item.closest(".carousel-module").attr("class", transitionClasses);
                }
                if (!isSame && !item.data("is-slide") && carousel.hasClass("fired-once") && item.attr("data-item-href")) {
                    site.dynamicRequest(item.attr("data-item-href"), {
                        requestName: item.attr("data-request-name"),
                        noScroll: item.data("no-scroll"),
                        noHistory: item.data("no-history"),
                        isSlide: item.data("is-slide")
                    });
                }
                // put the caption in the destination
                if (item.hasClass("slideshow-item")) {
                    var slideshow = item.closest(".slideshow");
                    var displayItems = item.find(".slideshow-item-display-content > div");
                    displayItems.each(function(index, displayItem) {
                        displayItem = $(displayItem);
                        var destination = displayItem.attr("data-destination");
                        if (destination) {
                            slideshow.find(destination).html(displayItem.html());
                        }
                    });
                }
                setupButtonLabels(item, carousel);
                carousel.addClass("fired-once");
                carousel.attr("data-selected-index", data.selectedIndex);
                $.event.trigger("site:loadImages");
            });

            flickityCarousel.on("settle.flickity", function() {
                var data = $(this).data("flickity");
                var item = $(data.selectedElement);
                var previousSelectedIndex = carousel.attr("data-settled-index") ? carousel.attr("data-settled-index") : "";
                var isSame = previousSelectedIndex.length && parseInt(previousSelectedIndex) == data.selectedIndex;
                if (!isSame && item.data("is-slide") && item.attr("data-item-href")) {
                    if (slideSettleTimeout) {
                        clearTimeout(slideSettleTimeout);
                        slideSettleTimeout = null;
                    }
                    slideSettleTimeout = setTimeout(function() {
                        site.dynamicRequest(item.attr("data-item-href"), {
                            requestName: item.attr("data-request-name"),
                            noScroll: item.data("no-scroll"),
                            noHistory: item.data("no-history"),
                            isSlide: item.data("is-slide")
                        });
                    }, 250);
                }
                $.event.trigger("site:loadImages");
                carousel.attr("data-settled-index", data.selectedIndex);
            });

            setTimeout(function() {
                flickityCarousel.flickity("resize");
            }, 100);
        });
    };

    var setupButtonLabels = function(item, carousel) {
        var previousLabelText = item.attr("data-previous-label");
        var nextLabelText = item.attr("data-next-label");
        var nextButton = carousel.find(".flickity-prev-next-button.next ");
        var previousButton = carousel.find(".flickity-prev-next-button.previous ");
        if (previousLabelText && previousButton.length) {
            if (carousel.find(".flickity-prev-next-button.previous span").length) {
                carousel.find(".flickity-prev-next-button.previous span").replaceWith("<span>" + previousLabelText + "</span>");
            } else {
                carousel.find(".flickity-prev-next-button.previous").append("<span>" + previousLabelText + "</span>");
            }
        }
        if (nextLabelText && nextButton.length) {
            if (carousel.find(".flickity-prev-next-button.next span").length) {
                carousel.find(".flickity-prev-next-button.next span").replaceWith("<span>" + nextLabelText + "</span>");
            } else {
                carousel.find(".flickity-prev-next-button.next").append("<span>" + nextLabelText + "</span>");
            }
        }
    };

    var _handleArrowClick = function(e) {
        e.preventDefault();
        var target = $(e.currentTarget);
        var direction = target.hasClass("previous") ? "previous" : "next";
        var slideshow = target.closest(".slideshow");
        var wrap = slideshow.find(".carousel-wrap");
        if (wrap.flickity) {
            wrap.flickity(direction, false, false);
        }
    };

    var _initHorizontalScrollers = function(e, obj) {
        $(".not-mobile-detected .content-card-scroller-wrap:not(.inited)").each(function(index, item) {
            var jItem = $(item);
            var myScroll = new IScroll(item, { scrollX: true, scrollY: false, tap: true });
            jItem.addClass("inited");
            jItem.find("a").addClass("ignore").on("click", function(e) {
                e.preventDefault();
            });
            jItem.find(".link").removeClass("link").addClass("fake-link").on("tap", _handleScrollTap);
        });
    };

    var _handleScrollTap = function(e) {
        e.preventDefault();
        site.handleClick(e);
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
                console.log("Carousels.init");
            }
            $(document).on("site:insert", _handleInsert);
            $(document).on("user:geotargetted css:loaded site:finishedInit carousels:resize", function(e) {
                $(".carousel.inited .carousel-wrap").each(function(index, item) {
                    item = $(item);
                    item.flickity("resize");
                });
            });
            $(document).on("user:geotargetted css:loaded site:finishedInit", function(e) {
                $(".scroll-nav.inited .scroll-nav-wrap").each(function(index, item) {
                    item = $(item);
                    item.find(".flickity-viewport").css("height", "");
                    item.flickity("resize");
                });
            });
            $(document).on("images:imageLoaded", function() {
                if (flickityResizeTimeout) {
                    clearTimeout(flickityResizeTimeout);
                    flickityResizeTimeout = null;
                }
                flickityResizeTimeout = setTimeout(function() {
                    $.event.trigger("carousels:resize");
                }, 100);
            });
            $(site.containers.main).on("click", ".scroll-nav a.ignore", function(e) {
                e.preventDefault();
            });
            $(site.containers.main).on("click", ".slideshow .slideshow-item-arrow", _handleArrowClick);
        }
    };
})();
