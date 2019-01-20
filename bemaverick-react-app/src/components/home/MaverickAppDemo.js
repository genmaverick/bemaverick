import React from 'react';
import MediaQuery from 'react-responsive';

const deviceImg = 'https://s3.amazonaws.com/bemaverick-website-images/maverick-app-demo.png';
const appDemoAnimation = 'https://s3.amazonaws.com/bemaverick-website-images/app-demo-animation.gif';

const styles = {
  imgContainer: {
    display: 'flex',
    flexDirection: 'column',
    justifyContent: 'center',
    alignItems: 'center',
    position: 'relative',
    width: '100%',
  },
  deviceImgXs: {
    width: '300px',
  },
  deviceImgSm: {
    width: '380px',
  },
  deviceImgMd: {
    width: '500px',
    marginTop: '120px',
  },
  deviceImgLg: {
    width: '500px',
    marginTop: '30px',
  },
  animationXs: {
    position: 'absolute',
    width: '96px',
    height: '164px',
    left: '198px',
    top: '47px',
    backgroundImage: `url(${appDemoAnimation})`,
    backgroundRepeat: 'no-repeat',
    backgroundPosition: 'top',
    backgroundSize: 'cover',
  },
  animationSm: {
    position: 'absolute',
    width: '122px',
    height: '207px',
    left: '251px',
    top: '60px',
    backgroundImage: `url(${appDemoAnimation})`,
    backgroundRepeat: 'no-repeat',
    backgroundPosition: 'top',
    backgroundSize: 'cover',
  },
  animationMd: {
    position: 'absolute',
    width: '160px',
    height: '275px',
    left: '331px',
    top: '197px',
    backgroundImage: `url(${appDemoAnimation})`,
    backgroundRepeat: 'no-repeat',
    backgroundPosition: 'top',
    backgroundSize: 'cover',
  },
  animationLg: {
    position: 'absolute',
    width: '160px',
    height: '275px',
    left: '331px',
    top: '109px',
    backgroundImage: `url(${appDemoAnimation})`,
    backgroundRepeat: 'no-repeat',
    backgroundPosition: 'top',
    backgroundSize: 'cover',
  },
  container: {
    position: 'relative',
  },
};

export default () => (
  <span>
    <MediaQuery query="(max-width: 400px)">
      <div style={styles.container}>
        <img src={deviceImg} style={styles.deviceImgXs} alt="maverick-app-devices" />
        <div style={styles.animationXs} />
      </div>
    </MediaQuery>
    <MediaQuery query="(min-width: 401px) and (max-width: 575px)">
      <div style={styles.container}>
        <img src={deviceImg} style={styles.deviceImgSm} alt="maverick-app-devices" />
        <div style={styles.animationSm} />
      </div>
    </MediaQuery>
    <MediaQuery query="(min-width: 576px) and (max-width: 991px)">
      <div style={styles.container}>
        <img src={deviceImg} style={styles.deviceImgMd} alt="maverick-app-devices" />
        <div style={styles.animationMd} />
      </div>
    </MediaQuery>
    <MediaQuery query="(min-width: 992px)">
      <div style={styles.container}>
        <img src={deviceImg} style={styles.deviceImgLg} alt="maverick-app-devices" />
        <div style={styles.animationLg} />
      </div>
    </MediaQuery>
  </span>
);
