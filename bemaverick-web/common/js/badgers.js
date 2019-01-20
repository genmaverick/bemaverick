window.MAV = window.MAV || {};
window.MAV.lib = window.MAV.lib || {};
window.MAV.lib.Badgers = (function() {
    var isInit = false;

    var _handleTriggerClick = function(e) {
        var badger = $(e.currentTarget).closest(".badger");
        _toggleBadger(badger);
    };

    var _toggleBadger = function(badger) {
        badger.toggleClass("show-badger");
    };

    var _hideBadgers = function(badgers) {
        badgers.removeClass("show-badger");
    };

    var _handleOtherClick = function(e) {
        var possibleBadgers = $("div.badger.show-badger");
        if (!possibleBadgers.length) {
            return;
        }
        var target = $(e.target);
        if (target.closest(".badger").length) {
            return;
        }
        _hideBadgers(possibleBadgers);
    };

    var _handleBadgeClick = function(e) {
        var target = $(e.currentTarget);
        var form = target.find("form");
        if (form.length) {
            form.submit();
        }
    };

    var _init = function() {
        $(site.containers.main).on("click", ".badger .badger__trigger", _handleTriggerClick);
        $(site.containers.main).on("click", ".badger .badge", _handleBadgeClick);
        $(site.containers.main).on("click", _handleOtherClick);
    };

    return {
        init: function(initSite, jquery) {
            if (isInit) {
                return;
            }
            isInit = true;
            $ = jquery;
            site = initSite;
            _init();
        }
    };
})();
