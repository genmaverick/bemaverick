import React from 'react';
import MediaQuery from 'react-responsive';
import HomePage from '../../layouts/HomePage';
import LeftColumn from '../../components/home/LeftColumn';
import TabbedSignin from '../../components/home/TabbedSignin';
import AppleStore from '../../components/icons/AppleStore';

const styles = {
  rightColumnMobile: {
    width: '100%',
    display: 'flex',
    flexDirection: 'column',
    justifyContent: 'center',
    alignItems: 'center',
  },
  rightColumnDesktop: {
    width: '100%',
    display: 'flex',
    flexDirection: 'column',
    justifyContent: 'center',
    alignItems: 'center',
  },
  appStoreMobile: {
    margin: '50px 0 40px 0',
  },
  appStoreTablet: {
    margin: '20px 0 20px 0',
  },
  appStoreDesktop: {
    margin: '20px 0 0 0',
  },
  signin: {
    marginBottom: '50px',
  },
};

export default () => (
  <HomePage title="Maverick Home" >
    {/* left column / children[0] */}
    <LeftColumn />
    {/* right column / children[1] */}
    <div style={styles.rightColumnDesktop}>
      <MediaQuery query="(max-width: 991px)">
        <div style={styles.rightColumnMobile}>
          <MediaQuery query="(max-width: 575px)">
            <AppleStore margin={styles.appStoreMobile} />
          </MediaQuery>
          <MediaQuery query="(min-width: 576px)">
            <AppleStore margin={styles.appStoreTablet} />
          </MediaQuery>
          <span style={styles.signin}><TabbedSignin style={styles.signin} /></span>
        </div>
      </MediaQuery>
      <MediaQuery query="(min-width: 992px)">
        <div style={styles.rightColumnDesktop}>
          <TabbedSignin />
          <AppleStore margin={styles.appStoreDesktop} />
        </div>
      </MediaQuery>
    </div>
  </HomePage>
);

