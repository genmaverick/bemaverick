window.ST = window.ST || {};
window.ST.lib = window.ST.lib || {};
window.ST.lib.Unicorns = (function() {
    var site = null;
    var isInit = false;
    var environment = "test";
    var didAttemptRender = false;
    var isRendering = false;
    var $ = null;
    var initialAttempt = 0;
    var timings = {};
    var availableAdSelectors = [];
    var ggt = null;
    var clearSelector = "inited inited--tablet empty not-empty inited--phone inited--desktop viewed viewed-estimated rendered displayed unicorn--loading";
    var doTime = function(mark, startMarkToUse, returnTime, clear) {
        if (!site.config.debugMode) {
            return null;
        }
        var timestamp = window.performance && window.performance.now ? window.performance.now() : new Date().getTime();
        if (!timings[mark] || clear) {
            timings[mark] = {
                start: timestamp,
                end: null,
                duration: null
            };
            return;
        }
        var startime = startMarkToUse && timings[startMarkToUse] ? timings[startMarkToUse]["start"] : timings[mark]["start"];
        timings[mark]["end"] = timings[mark]["end"] ? timings[mark]["end"] : timestamp;
        timings[mark]["duration"] = parseFloat((timings[mark]["end"] - startime).toFixed(2));
        if (returnTime) {
            return timings[mark]["duration"];
        }
    };

    var addLoadClass = function(id) {
        setTimeout(function() {
            $("#" + id).addClass("unicorn--loading");
        }, 0);
    };

    var showInViewAds = function(forceRender) {
        if (isRendering && !forceRender) {
            return;
        }
        if (!window.googletag || site.isClearingUnicorns) {
            return;
        }
        var layout = site.layout && site.layout.unicornType ? site.layout.unicornType : site.detectedMobile ? "phone" : "desktop";
        var selector = $(".type-posts").length && layout != "phone" ? ".tracked .unicorn:not(.inited)" : ".unicorn:not(.inited)";
        var elems = $(selector);
        var idsToDisplay = [];
        var slotsToRender = [];

        var domainPath = $.browser.mobile ? "m.aspworldtour" : "aspworldtour";

        elems.each(function(index, elem) {
            elem = $(elem);
            if (elem.height() && elem.css("display") != "none") {
                var adHeight = elem.attr("data-height") ? parseInt(elem.attr("data-height")) : elem.height();
                elem.attr("data-height", adHeight);
                site.generateId(elem);
                offset = layout == "phone" ? $(window).height() + adHeight : 0;
                offset = elem.hasClass("unicorn--placeholder") ? 0 : offset;
                var isVisible = false;

                elem.isOnScreen({ top: offset, bottom: offset, left: 0, right: 0 }).each(function(index, elem) {
                    isVisible = true;
                });
                if (!isVisible && elem.hasClass("unicorn--always-visible")) {
                    isVisible = true;
                }
                if (isVisible) {
                    if (elem.hasClass("unicorn--placeholder")) {
                        var selector = elem.attr("data-unicorn-refresh");
                        if (!forceRender && selector && $(selector).length) {
                            var oldElem = elem;
                            oldElem.addClass("inited");
                            elem = $(selector);
                            elem.removeClass("inited viewed viewed-estimated");
                        } else {
                            return true;
                        }
                    }

                    var id = elem.attr("id");
                    doTime(id, null, null, true);
                    elem.addClass("shown inited inited--" + layout);
                    if (site.slots[id] && site.slots[id].displayed) {
                        var slot = site.slots[id].slot;
                        slotsToRender.push(slot);
                    } else {
                        var settings = elem.attr("data-unicorn-settings");
                        try {
                            var group = layout == "phone" ? null : elem.attr("data-unicorn-group");
                            settings = $.parseJSON(settings);
                            if (settings[layout]) {
                                var slotName = settings[layout]["slotName"].replace(":DOMAIN_PATH", domainPath);
                                if (settings[layout]["outOfPage"]) {
                                    var slot = window.googletag.defineOutOfPageSlot(slotName, id).addService(window.googletag.pubads());
                                } else {
                                    var slot = window.googletag.defineSlot(slotName, settings[layout]["sizes"], id).addService(window.googletag.pubads());
                                }

                                if (settings[layout]["shouldCollapse"]) {
                                    slot.setCollapseEmptyDiv(true);
                                }

                                if (settings[layout]["targeting"]) {
                                    var targeting = settings[layout]["targeting"];
                                    $.each(targeting, function(k, v) {
                                        if (false && (k == "topic" || k == "franchise")) {
                                            var vs = v.split(",");
                                            for (var vi = 0; vi < vs.length; vi++) {
                                                slot.setTargeting(k + "-" + (vi + 1), vs[vi]);
                                            }
                                        } else if (v) {
                                            slot.setTargeting(k, v + "");
                                        }
                                    });
                                }
                                site.slots[id] = {
                                    slot: slot,
                                    displayed: true,
                                    group: group
                                };
                                idsToDisplay.push(id);
                                slotsToRender.push(slot);
                            }
                        } catch (e) {
                            if (window.console) {
                                console.error(e);
                            }
                        }
                    }
                }
            }
        });

        if (idsToDisplay.length) {
            $.each(idsToDisplay, function(index, id) {
                window.googletag.cmd.push(function() {
                    doTime(id, null, null, true);
                    window.googletag.display(id);
                    addLoadClass(id);
                });
            });
        }
        if (slotsToRender.length) {
            window.googletag.cmd.push(function() {
                window.googletag.pubads().refresh(slotsToRender);
            });
        }
        isRendering = false;
    };

    var isEnabled = false;
    var loadGoogle = function(e, obj) {
        obj = obj ? obj : {};
        if (!isEnabled) {
            window.googletag = window.googletag || {};
            googletag.cmd = googletag.cmd || [];
            isEnabled = true;
            googletag.cmd.push(function() {
                window.googletag.pubads().enableSingleRequest();
                window.googletag.pubads().disableInitialLoad();
                window.googletag.pubads().addEventListener("impressionViewable", function(event) {
                    var id = event && event.slot && event.slot.getSlotElementId ? event.slot.getSlotElementId() : "";
                    if (id && $("#" + id).length) {
                        $("#" + id).addClass("viewed");
                    }
                });
                if (site.config.debugMode) {
                    window.googletag.pubads().addEventListener("slotRenderEnded", function(event) {
                        var id = event && event.slot && event.slot.getSlotElementId ? event.slot.getSlotElementId() : "";
                        var adUnitPath = event && event.slot && event.slot.getAdUnitPath ? event.slot.getAdUnitPath() : "";
                        if (id && $("#" + id).length) {
                            $("#" + id).addClass("rendered");
                            var endTime = doTime(id, null, true);
                            if (site.config.debugMode && endTime) {
                                var displayPieces = adUnitPath.split("/");
                                var displayAdUnitPath = displayPieces.length ? displayPieces[displayPieces.length - 1] : "";
                                var targetingKeys = event && event.slot && event.slot.getTargetingKeys ? event.slot.getTargetingKeys() : [];
                                var targetingString = "";
                                for (var i = 0; i < targetingKeys.length; i++) {
                                    targetingString +=
                                        "<span><strong>" +
                                        targetingKeys[i] +
                                        "</strong><em>" +
                                        event.slot.getTargeting(targetingKeys[i]).join("<br>") +
                                        "</em></span>";
                                }
                                $("#" + id).append(
                                    '<span class="timing">' +
                                        targetingString +
                                        "<span><strong>slotname</strong><em>" +
                                        adUnitPath +
                                        "</em></span><span>Correlate-Render:<em>" +
                                        endTime +
                                        "</em></span></span>"
                                );
                            }
                            setTimeout(function() {
                                $("#" + id).addClass("viewed-estimated");
                            }, 2000);
                            $.event.trigger("video:position-proxy");
                            $.event.trigger("unicorn:slotRenderEnded");
                            if (!event.isEmpty) {
                                $("#" + id).addClass("not-empty");
                            } else {
                                $("#" + id).addClass("empty");
                            }
                        }
                    });
                } else {
                    window.googletag.pubads().addEventListener("slotRenderEnded", function(event) {
                        var id = event && event.slot && event.slot.getSlotElementId ? event.slot.getSlotElementId() : "";
                        if (id && $("#" + id).length) {
                            $("#" + id).addClass("rendered");
                            setTimeout(function() {
                                $("#" + id).addClass("viewed-estimated");
                            }, 2000);
                            $.event.trigger("video:position-proxy");
                            $.event.trigger("unicorn:slotRenderEnded");
                            if (!event.isEmpty) {
                                $("#" + id).addClass("not-empty");
                            } else {
                                $("#" + id).addClass("empty");
                            }
                        }
                    });
                }
                window.googletag.enableServices();
            });
        }
        var layout = site.layout && site.layout.unicornType ? site.layout.unicornType : site.detectedMobile ? "phone" : "desktop";
        var prefix = obj && obj.unicornSelector ? obj.unicornSelector + " " : "";
        var clearUnicorns = obj && obj.unicornClear && obj.unicornClear.indexOf(layout) !== -1;

        if (prefix && clearUnicorns) {
            $(prefix)
                .removeClass(clearSelector)
                .attr("style", "");
        }

        if (obj.unicornSettings && obj.unicornSettings.targeting) {
            var changed = checkForTargetingChange(obj.unicornSettings.targeting);
            if (site.config.debugMode) {
                console.log("changed", changed);
            }
            if (changed) {
                $(".unicorn:not(.unicorn--empty)")
                    .removeClass(clearSelector)
                    .attr("style", "");
            }
            $.event.trigger("video:update-targeting", obj.unicornSettings);
        }

        googletag.cmd.push(function() {
            isRendering = true;
            showInViewAds(true);
        });
    };

    var handleInViewAds = function(e, obj) {
        if (site.isClearingUnicorns) {
            return;
        }
        googletag.cmd.push(function() {
            showInViewAds(false);
        });
    };

    var handleInsert = function(e, obj) {
        loadGoogle(e, obj);
    };

    var refreshAds = function(e, obj) {
        $(".unicorn:not(.unicorn--empty)")
            .removeClass(clearSelector + " unicorn--always-visible")
            .attr("style", "");
        if (site.config.debugMode) {
            console.log("refreshhhh");
        }
        googletag.cmd.push(function() {
            showInViewAds(false);
        });
    };

    var refreshViewedAds = function(e, obj) {
        $(".unicorn.viewed:not(.unicorn--empty)")
            .removeClass(clearSelector)
            .attr("style", "");
        if (site.config.debugMode) {
            console.log("refreshhhh viewed");
        }
        googletag.cmd.push(function() {
            showInViewAds(false);
        });
    };

    var checkForTargetingChange = function(newTargeting) {
        var unicorns = $(".unicorn:not(.unicorn--empty)");
        var changed = false;
        unicorns.each(function(index, unicorn) {
            var elem = $(unicorn);
            var settings = elem.attr("data-unicorn-settings");
            try {
                settings = JSON.parse(settings);
                var oldTargeting = settings && settings.desktop && settings.desktop.targeting ? settings.desktop.targeting : null;
                if (oldTargeting) {
                    if (oldTargeting["pos"]) {
                        newTargeting["pos"] = oldTargeting["pos"];
                    }
                    if (JSON.stringify(oldTargeting) != JSON.stringify(newTargeting)) {
                        settings.desktop.targeting = newTargeting;
                        if (settings.phone && settings.phone.targeting) {
                            settings.phone.targeting = newTargeting;
                        }
                        elem.attr("data-unicorn-settings", JSON.stringify(settings));
                        var id = elem.attr("id");
                        if (id) {
                            site.destroySlot(id);
                            elem.attr("id", id + "-");
                            changed = true;
                        }
                    }
                }
            } catch (e) {
                if (window.console) {
                    console.error(e);
                }
            }
        });
        return changed;
    };

    var changeLayoutTimeout = null;
    var _handleChangeLayout = function(e, obj) {
        if (obj && obj.current && obj.previous && obj.current.unicornType != obj.previous.unicornType) {
            if (changeLayoutTimeout) {
                clearTimeout(changeLayoutTimeout);
                changeLayoutTimeout = null;
            }
            changeLayoutTimeout = setTimeout(function() {
                $(".unicorn:not(.unicorn--empty)")
                    .removeClass(clearSelector + " unicorn--always-visible")
                    .attr("style", "")
                    .attr("id", "");
                loadGoogle(null, { clearUnicorns: true });
            }, 2000);
        }
    };
    return {
        init: function(initSite, jquery) {
            if (isInit || !initSite || !initSite.config || !initSite.config.unicornsEnabled) {
                return;
            }
            isInit = true;
            $ = jquery;
            site = initSite;
            if (site.config.debugMode) {
                console.log("Unicorns.init");
            }

            environment = initSite.config.unicornsEnvironment;
            $(document).on("unicorns:insert", function(e, obj) {
                handleInsert(e, obj);
            });
            $(document).on("unicorns:refresh", function(e, obj) {
                refreshAds(e, obj);
            });

            $(document).on("unicorns:refresh-viewed", function(e, obj) {
                refreshViewedAds(e, obj);
            });

            $(window).on("resize scroll site:show-in-view-ads", handleInViewAds);
            $(document).on("site:fullPage", function(e, obj) {
                $("form.trc-hidden+span").remove();
                $("form.trc-hidden").remove();
            });
            $(document).on("site:changeLayout", _handleChangeLayout);
        }
    };
})();
