/* eslint-disable-line no-undef */
import React from 'react';
import Safe from 'react-safe';
import config from '../../../utils/config';

// in render
export default () => (
  <Safe.script>
    {`// load Branch
    (function(b,r,a,n,c,h,_,s,d,k){if(!b[n]||!b[n]._q){for(;s<_.length;)c(h,_[s++]);d=r.createElement(a);d.async=1;d.src="https://cdn.branch.io/branch-latest.min.js";k=r.getElementsByTagName(a)[0];k.parentNode.insertBefore(d,k);b[n]=h}})(window,document,"script","branch",function(b,r){b[r]=function(){b._q.push([r,arguments])}},{_q:[],_v:1},"addListener applyCode autoAppIndex banner closeBanner closeJourney creditHistory credits data deepview deepviewCta first getCode init link logout redeem referrals removeListener sendSMS setBranchViewData setIdentity track validateCode trackCommerceEvent".split(" "), 0);
    // init Branch
    branch.init("${config.maverickBranch.key}");
    if (window) {
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
    `}
  </Safe.script>
);
