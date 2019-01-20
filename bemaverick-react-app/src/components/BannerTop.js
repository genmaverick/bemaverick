import React from 'react';
import PropTypes from 'prop-types';
import logoImgUrl from '../assets/images/logo-brandmark-2.svg';

const styles = {
  imageBanner: {
    display: 'flex',
    justifyContent: 'center',
    alignItems: 'center',
    position: 'relative',
    width: '100%',
    height: '40vh',
    background: 'linear-gradient(45deg, #2d4670 0%,#1e6f8e 16%,#00a8b0 46%)',
    backgroundRepeat: 'no-repeat',
    backgroundPosition: 'top',
    backgroundSize: 'cover',
  },
  plainBanner: {
    display: 'flex',
    justifyContent: 'center',
    alignItems: 'center',
    position: 'relative',
    width: '100%',
    height: '25vh',
    backgroundColor: '#098c87',
    background: 'linear-gradient(45deg, #2d4670 0%,#1e6f8e 16%,#00a8b0 46%)',
  },
  plainBannerLogo: {
    position: 'absolute',
    height: '70%',
    opacity: '0.2',
  },
};

const BannerImageTop = ({ url }) => {
  if (url !== '') {
    return (
      <div style={{ ...styles.imageBanner, backgroundImage: `url(${url})` }} />
    );
  }
  return (
    <div style={styles.plainBanner} >
      <img src={logoImgUrl} alt="maverick-logo" style={styles.plainBannerLogo} />
    </div>
  );
};

BannerImageTop.propTypes = {
  url: PropTypes.string,
};

BannerImageTop.defaultProps = {
  url: '',
};

export default BannerImageTop;
