window.MAV = window.MAV || {};
window.MAV.controllers = window.MAV.controllers || {};
window.MAV.controllers.Responses = (function() {
    var site = null;
    var isInit = false;
    var $ = null;

    var _updateResponseStatuses = function(responseStatuses) {
        $.each(responseStatuses, function(index, responseStatus) {
            items = $(site.containers.main + ' [data-response-id="' + responseStatus.id + '"]');
            if (items.length) {
                items.attr("data-response-status", responseStatus.status);
            }
        });
    };

    var _init = function(e, obj) {
        if (obj.subType == "response-status-edit-confirm") {
            _updateResponseStatuses(obj.responseStatuses);
            site.hidePopup();
        }

        if (e) {
            $.event.trigger("site:finishInit", obj);
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
                console.log("Responses.init");
            }
            $(document).on("responses:init", _init);
        }
    };
})();
