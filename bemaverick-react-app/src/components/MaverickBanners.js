import React from 'react';
import MediaQuery from 'react-responsive';
import bannerImg from '../assets/images/maverick-name-banner.png';
import rectangleImg from '../assets/images/skewed-rectangle-small.svg';
import AppleStore from '../components/icons/AppleStore';

const styles = {
  imgContainer: {
    display: 'flex',
    flexDirection: 'column',
    justifyContent: 'center',
    alignItems: 'center',
    position: 'relative',
    width: '100%',
    margin: '15px 0 15px 0',
  },
  bannerImgMobile: {
    position: 'relative',
    width: '85%',
    margin: '0 0 10px 0',
  },
  bannerImgDesktop: {
    position: 'relative',
    width: '80%',
    margin: '-40px 0 10px 0',
  },
  rectangleMobile: {
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    width: '90%',
  },
  rectangleDesktop: {
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    width: '90%',
    marginTop: '30px',
  },
  rectangleImg: {
    height: '100%',
    width: '100%',
  },
  rectangleTextMobile: {
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    position: 'absolute',
    width: '100%',
    color: '#ffffff',
    fontStyle: 'italic',
    fontSize: '4vw',
  },
  rectangleTextDesktop: {
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    position: 'absolute',
    width: '100%',
    color: '#ffffff',
    fontStyle: 'italic',
    fontSize: '2vw',
  },
  signin: {
    display: 'block',
    position: 'relative',
    textTransform: 'uppercase',
    fontSize: '3.8vw',
    fontWeight: 700,
    margin: '45px 0 0 0',
    whiteSpace: 'nowrap',
  },
  test: {
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center',
    justifyContent: 'center',
    position: 'relative',
    width: '100%',
    height: '100%',
  },
  appStore: {
    width: '150px',
    marginTop: '30px',
  },
};

export default () => (
  <div style={styles.imgContainer}>
    <MediaQuery query="(max-width: 765px)">
      <img src={bannerImg} style={styles.bannerImgMobile} alt="maverick-app-devices" />
      <div style={styles.rectangleMobile}>
        <img src={rectangleImg} style={styles.rectangleImg} alt="web-and-mobile" />
        <div style={styles.rectangleTextMobile}>
          #DOYOURTHING ON THE WEB AND ON THE APP!
        </div>
      </div>
      <div style={styles.signin}>
        {"(You'll need to sign up or sign in to view this!)"}
      </div>
    </MediaQuery>
    <MediaQuery query="(min-width: 766px)">
      <div style={styles.test}>
        <img src={bannerImg} style={styles.bannerImgDesktop} alt="maverick-app-devices" />
        <div style={styles.rectangleDesktop}>
          <img src={rectangleImg} style={styles.rectangleImg} alt="web-and-mobile" />
          <div style={styles.rectangleTextDesktop}>
            #DOYOURTHING ON THE WEB AND ON THE APP!
          </div>
        </div>
        <AppleStore margin={styles.appStore} />
      </div>
    </MediaQuery>
  </div>
);
