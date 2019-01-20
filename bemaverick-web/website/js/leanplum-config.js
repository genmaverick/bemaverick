window.MAV = window.MAV || {};
window.MAV.lib = window.MAV.lib || {};
window.MAV.lib.LeanplumConfig = (function() {
    var site = null;
    var isInit = false;
    var $ = null;
    var leanplumAppId = "";
    var leanplumClientKey = "";

    var initLeanplum = function() {
        if (site.config && site.config.leanplumAppId) {
            leanplumAppId = site.config.leanplumAppId;
            leanplumClientKey = site.config.leanplumClientKey;
        }
        if (window) {
            const isDevelopmentMode = (leanplumAppId.slice(0,6) === 'app_0S') ? true : false;
            if (isDevelopmentMode) {
                Leanplum.setAppIdForDevelopmentMode(leanplumAppId, leanplumClientKey);
            } else {
                Leanplum.setAppIdForProductionMode(leanplumAppId, leanplumClientKey);
            }

            Leanplum.start(function(success) {
                console.log('Success: ' + success);
            });
        }
    };

    // var handleLeanplumAdvance = function() {
    //     if (window) {
    //         Leanplum.advanceTo(window.location.pathname);
    //     }
    // };

    return {
        init: function(initSite, jquery) {
            if (isInit) {
                return;
            }
            isInit = true;
            $ = jquery;
            site = initSite;
            initLeanplum();
            // handleLeanplumAdvance();
            // $(document).on("site:handleLeanplumAdvance", handleLeanplumAdvance);
        }
    };
})();
