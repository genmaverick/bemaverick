window.MAV = window.MAV || {};
window.MAV.lib = window.MAV.lib || {};
window.MAV.lib.SegmentConfig = (function() {
    var site = null;
    var isInit = false;
    var $ = null;
    var segmentKey = "";
    var identifyCalled = false;
    var loaded = false;
    var handleSegment = function(e, obj) {
        var pageTracking = obj.pageTracking;
        var pageData = pageTracking.page ? pageTracking.page : {};
        if (!loaded) {
            // prettier-ignore
            !function(){var analytics=window.analytics=window.analytics||[];if(!analytics.initialize)if(analytics.invoked)window.console&&console.error&&console.error("Segment snippet included twice.");else{analytics.invoked=!0;analytics.methods=["trackSubmit","trackClick","trackLink","trackForm","pageview","identify","reset","group","track","ready","alias","debug","page","once","off","on"];analytics.factory=function(t){return function(){var e=Array.prototype.slice.call(arguments);e.unshift(t);analytics.push(e);return analytics}};for(var t=0;t<analytics.methods.length;t++){var e=analytics.methods[t];analytics[e]=analytics.factory(e)}analytics.load=function(t,e){var n=document.createElement("script");n.type="text/javascript";n.async=!0;n.src=("https:"===document.location.protocol?"https://":"http://")+"cdn.segment.com/analytics.js/v1/"+t+"/analytics.min.js";var o=document.getElementsByTagName("script")[0];o.parentNode.insertBefore(n,o);analytics._loadOptions=e};analytics.SNIPPET_VERSION="4.1.0";
                analytics.load(segmentKey);
                loaded = true;
                if ( !identifyCalled && pageTracking.userId && pageTracking.identify ) {
                    analytics.identify(pageTracking.userId, pageTracking.identify);
                    identifyCalled = true;
                }
                analytics.page(pageData);
            }}();
        } else {
            if (!identifyCalled && pageTracking.userId && pageTracking.identify) {
                analytics.identify(pageTracking.userId, pageTracking.identify);
                identifyCalled = true;
            }
            analytics.page(pageData);
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
            segmentKey = site.config && site.config.segmentKey ? site.config.segmentKey : null;
            if (segmentKey) {
                $(document).on("site:trackPage", handleSegment);
            }
        }
    };
})();
