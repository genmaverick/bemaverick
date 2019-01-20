import React from 'react';
import MediaQuery from 'react-responsive';
import SixSixNoNavPage from '../../layouts/SixSixNoNavPage';
import MaverickBanners from '../../components/MaverickBanners';
import TabbedSignin from '../../components/home/TabbedSignin';

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
  appStoreTablet: {
    margin: '-70px 0 40px 0',
  },
  appStoreDesktop: {
    margin: '20px 0 0 0',
  },
  signinDesktop: {
    display: 'block',
    position: 'relative',
    textTransform: 'uppercase',
    fontSize: '1.9vw',
    fontWeight: 700,
    margin: '0 0 30px 0',
    whiteSpace: 'nowrap',
  },
};

export default () => (
  <SixSixNoNavPage title="Not Logged In!" >
    {/* left column / children[0] */}
    <MaverickBanners />
    {/* right column / children[1] */}
    <div style={styles.rightColumnDesktop}>
      <MediaQuery query="(max-width: 765px)">
        <div style={styles.rightColumnMobile}>
          <TabbedSignin />
        </div>
      </MediaQuery>
      <MediaQuery query="(min-width: 766px)">
        <div style={styles.rightColumnDesktop}>
          <div style={styles.signinDesktop}>
            {"(You'll need to sign up or sign in to view this!)"}
          </div>
          <TabbedSignin />
        </div>
      </MediaQuery>
    </div>
  </SixSixNoNavPage>
);

