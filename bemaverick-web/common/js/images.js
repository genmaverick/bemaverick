window.ST = window.ST || {};
window.ST.lib = window.ST.lib || {};
window.ST.lib.Images = (function() {
    var site = null;
    var isInit = false;
    var $ = null;
    var fbInited = false;
    var fbCalled = true;
    var isInitialCall = true;

    var initContentImages = function(container) {
        var i = 1;
        var offset = site.config.scrollLoadThreshold;
        var container = container ? container : $("body");
        var winWidth = $(window).width();
        var images = container.find(".proxy-img:not(.img-inited)");
        images.each(function(index, img) {
            img = $(img);
            if (img.css("display") != "none") {
                var isOnScreen =
                    img.closest("#popup").length ||
                    img.isOnScreen({
                        top: offset,
                        bottom: offset,
                        left: winWidth,
                        right: winWidth
                    }).length
                        ? true
                        : false;

                if (isOnScreen) {
                    if (img.outerHeight()) {
                        img.addClass("img-inited");
                        var dest = img;
                        var useImage = false;
                        var src = img.attr("data-img-src").replace("[TIMESTAMP]", new Date().getTime());
                        if (img.find(".dest").length) {
                            dest = img.find(".dest");
                            if (dest.hasClass("use-image--" + site.layout.name)) {
                                useImage = true;
                            }
                        } else if (dest[0].nodeName == "IMG" && dest.hasClass("use-this-img")) {
                            useImage = true;
                        }
                        if (img.attr("data-pixel-id")) {
                            $('[data-pixel-id="' + img.attr("data-pixel-id") + '"]')
                                .not(img)
                                .remove();
                        }

                        if (dest[0].nodeName == "IMG" && img.attr("data-placeholder-src")) {
                            dest.attr("src", img.attr("data-placeholder-src"));
                        }

                        setTimeout(function() {
                            $('<img src="' + src + '">').imagesLoaded(function() {
                                if (useImage) {
                                    dest.attr("src", src);
                                } else {
                                    dest.css("backgroundImage", "url(" + src + ")");
                                }
                                img.addClass("loaded");
                                $.event.trigger("images:imageLoaded");
                            });
                        }, 0);
                    }
                }
            }
        });
    };

    var initContentIframes = function(container) {
        var i = 1;
        var offset = site.config.scrollLoadThreshold;
        var container = container ? container : $("body");
        var winWidth = $(window).width();
        var images = container.find(".proxy-iframe:not(.iframe-inited)");
        images.each(function(index, iframe) {
            if ($(iframe).css("display") != "none") {
                $(iframe)
                    .isOnScreen({
                        top: offset,
                        bottom: offset,
                        left: winWidth,
                        right: winWidth
                    })
                    .each(function(i, iframe) {
                        var iframe = $(iframe);

                        if (iframe.outerHeight()) {
                            var src = iframe.attr("data-iframe-src").replace("[TIMESTAMP]", new Date().getTime());
                            iframe.addClass("iframe-inited");
                            iframe
                                .find(".iframe-destination")
                                .html(
                                    '<iframe scrolling="no" frameborder="0" allowfullscreen="1" width="100%" height="100%" src="' +
                                        src +
                                        '" class="loading"></iframe>'
                                );
                        }
                    });
            }
        });
    };

    var videoCount = 1;
    var initInlineVideos = function(container) {
        var i = 1;
        var offset = site.config.scrollLoadThreshold;
        var container = container ? container : $("body");
        var winWidth = $(window).width();
        var videos = container.find(".proxy-inline-video");
        var useMobile = site.detectedMobile;
        videos.each(function(index, video) {
            if ($(video).css("display") != "none") {
                $(video)
                    .isOnScreen({
                        top: offset,
                        bottom: offset,
                        left: winWidth,
                        right: winWidth
                    })
                    .each(function(i, video) {
                        var video = $(video);
                        if (video.outerHeight()) {
                            var poster = video.attr("data-video-poster");
                            var attributes = video.attr("data-video-attributes");
                            var id = "inserted-video--" + videoCount++;
                            var sources = video.data("video-sources");
                            var html = '<video preload="metadata" ' + attributes;
                            if (poster) {
                                html += ' poster="' + poster + '" >';
                            }

                            $.each(sources, function(index, source) {
                                var use = true;
                                if (useMobile && !source.mobile) {
                                    use = false;
                                }
                                if (use) {
                                    html += '<source type="' + source.type + '" src="' + source.filename + '"/>';
                                }
                            });
                            html += "</video>";

                            html = $(html);
                            html.on("loadedmetadata", function(e) {
                                $.event.trigger("video:loadedmetadata", { selector: "#" + id });
                            });

                            var container = video.closest(".proxy-video-player");
                            if (container.length) {
                                container.attr("id", id);
                            }
                            video.replaceWith(html);
                            $.event.trigger("video:inserted", { selector: "#" + id });
                            if (window.objectFitVideos) {
                                window.objectFitVideos();
                            }
                        }
                    });
            }
        });
    };

    var handleInsert = function(e, obj) {
        var container = obj.module ? obj.module : $(site.containers.content);
        setTimeout(function() {
            isInitialCall = false;
            initContentImages(container);
            initContentIframes(container);
            initInlineVideos(container);
        }, 0);
    };

    return {
        init: function(initSite, jquery) {
            if (isInit) {
                return;
            }
            isInit = true;
            $ = jquery;
            site = initSite;
            $(document).on("site:finishInit", handleInsert);
            $(window).on("resize site:scroll site:finishedInit masonry:layoutComplete site:insert site:loadImages css:loaded", function(e) {
                initContentImages();
                initContentIframes();
                initInlineVideos();
            });
        }
    };
})();
