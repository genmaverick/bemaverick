window.MAV = window.MAV || {};
window.MAV.lib = window.MAV.lib || {};
window.MAV.lib.BranchConfig = (function() {
    var site = null;
    var isInit = false;
    var $ = null;
    var branchKey = "";

    return {
        init: function(initSite, jquery) {
            if (isInit) {
                return;
            }
            isInit = true;
            $ = jquery;
            site = initSite;
            if (site.config && site.config.branchKey) {
                branchKey = site.config.branchKey;
            }
            if (window) {
                // load Branch
                (function(b,r,a,n,c,h,_,s,d,k){if(!b[n]||!b[n]._q){for(;s<_.length;)c(h,_[s++]);d=r.createElement(a);d.async=1;d.src="https://cdn.branch.io/branch-latest.min.js";k=r.getElementsByTagName(a)[0];k.parentNode.insertBefore(d,k);b[n]=h}})(window,document,"script","branch",function(b,r){b[r]=function(){b._q.push([r,arguments])}},{_q:[],_v:1},"addListener applyCode autoAppIndex banner closeBanner closeJourney creditHistory credits data deepview deepviewCta first getCode init link logout redeem referrals removeListener sendSMS setBranchViewData setIdentity track validateCode trackCommerceEvent".split(" "), 0);
                // init Branch
                branch.init(branchKey);
                var type = window.location.pathname.split('/')[1];
                if ( type == 'users' || type == 'challenges' || type == 'responses') {
                    type = type.substring(0, type.length-1);
                }
                branch.setBranchViewData({
                    data: {
                        '$deeplink_path': window.location.pathname,
                        'type': type,
                        'id': window.location.pathname.split('/')[2]
                    }
                });
            }
        }
    };
})();
