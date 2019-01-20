import React from 'react';
import MediaQuery from 'react-responsive';
import AppleStore from '../components/icons/AppleStore';

const styles = {
  footerContainer: {
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'space-between',
    position: 'relative',
    height: '60px',
    background: '#f1495b',
    color: '#ffffff',
    fontWeight: 500,
    fontSize: '2.5vw',
    padding: '0 10px 0 10px',
  },
  appStore: {
    height: '30px',
  },
};

export default () => (
  <div>
    <MediaQuery query="(max-width: 766px)">
      <div style={styles.footerContainer}>
        DOWNLOAD MAVERICK IN THE APP STORE!
        <AppleStore width="125px" />
      </div>
    </MediaQuery>
    <MediaQuery query="(min-width: 576px)">
      <div />
    </MediaQuery>
  </div>
);
