import React from 'react';
import MediaQuery from 'react-responsive';
import bannerImg from '../../assets/images/maverick-name-banner.png';
import rectangleImg from '../../assets/images/skewed-rectangle-small.svg';
import MaverickAppDemo from './MaverickAppDemo';

const styles = {
  imgContainer: {
    display: 'flex',
    flexDirection: 'column',
    justifyContent: 'center',
    alignItems: 'center',
    position: 'relative',
    width: '100%',
  },
  bannerImgMobile: {
    position: 'relative',
    width: '90%',
    margin: '15px 0 30px 0',
  },
  bannerImgTablet: {
    position: 'absolute',
    height: '15%',
    top: '7%',
    left: '8%',
  },
  bannerImgDesktop: {
    position: 'absolute',
    height: '15%',
    top: '3%',
    left: '8%',
  },
  rectangleMobile: {
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    width: '90%',
    margin: '20px 0 -20px 0',
    position: 'relative',
  },
  rectangleTablet: {
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    width: '450px',
    margin: '15px 0 0 25px',
    position: 'relative',
  },
  rectangleDesktop: {
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    width: '500px',
    margin: '15px 0 0 25px',
    position: 'relative',
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
    width: '90%',
    color: '#ffffff',
    fontStyle: 'italic',
    fontSize: '4.5vw',
  },
  rectangleTextTablet: {
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    position: 'absolute',
    width: '90%',
    color: '#ffffff',
    fontStyle: 'italic',
    fontSize: '22px',
  },
  rectangleTextDesktop: {
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    position: 'absolute',
    width: '90%',
    color: '#ffffff',
    fontStyle: 'italic',
    fontSize: '24px',
  },
};

export default () => (
  <div style={styles.imgContainer}>
    <MediaQuery query="(max-width: 575px)">
      <img src={bannerImg} style={styles.bannerImgMobile} alt="maverick-app-devices" />
      <MaverickAppDemo />
      <div style={styles.rectangleMobile}>
        <img src={rectangleImg} style={styles.rectangleImg} alt="web-and-mobile" />
        <div style={styles.rectangleTextMobile}>
        A creative community for girls
        </div>
      </div>
    </MediaQuery>
    <MediaQuery query="(min-width: 576px) and (max-width: 991px)">
      <MaverickAppDemo />
      <img src={bannerImg} style={styles.bannerImgTablet} alt="maverick-app-devices" />
      <div style={styles.rectangleTablet}>
        <img src={rectangleImg} style={styles.rectangleImg} alt="web-and-mobile" />
        <div style={styles.rectangleTextTablet}>
        A creative community for girls
        </div>
      </div>
    </MediaQuery>
    <MediaQuery query="(min-width: 992px)">
      <MaverickAppDemo />
      <img src={bannerImg} style={styles.bannerImgDesktop} alt="maverick-app-devices" />
      <div style={styles.rectangleDesktop}>
        <img src={rectangleImg} style={styles.rectangleImg} alt="web-and-mobile" />
        <div style={styles.rectangleTextDesktop}>
        A creative community for girls
        </div>
      </div>
    </MediaQuery>
  </div>
);
