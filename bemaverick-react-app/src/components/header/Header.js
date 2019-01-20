/* eslint-disable no-undef */
import React from 'react';
import MediaQuery from 'react-responsive';
import NProgress from 'nprogress';
import Router from 'next/router';
import MobileSidebarMenu from './MobileSidebarMenu';
import NavBar from './NavBar';
import NavBarLinks from './NavBarLinks';

Router.onRouteChangeStart = () => {
  NProgress.configure({ showSpinner: false });
  NProgress.start();
};
Router.onRouteChangeComplete = () => {
  NProgress.done();
  // google analytics through segment page change
  if (window.analytics) {
    window.analytics.page();
  }
  // leanplum page change
  if (window.leanplum && window.location) {
    window.leanplum.advanceTo(window.location.pathname);
  }
};
Router.onRouteChangeError = () => NProgress.done();

export default () => (
  <div>
    <NavBar>
      <MediaQuery query="(max-width: 766px)">
        <MobileSidebarMenu />
      </MediaQuery>
      <MediaQuery query="(min-width: 767px)">
        <NavBarLinks />
      </MediaQuery>
    </NavBar>
  </div>
);
