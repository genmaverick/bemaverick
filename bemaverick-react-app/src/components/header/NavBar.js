import React from 'react';
import PropTypes from 'prop-types';
import Icon from '../Icon';
import { warmGreyBackgroundLight } from '../../assets/colors';
import logoImgUrl from '../../assets/images/logo-secondary-black.svg';

const styles = {
  bannerContainer: {
    display: 'flex',
    alignItems: 'center',
    position: 'relative',
    width: '100%',
    height: '60px',
    backgroundColor: warmGreyBackgroundLight,
  },
  logo: {
    height: '40px',
    marginLeft: '5vw',
  },
  navContainer: {
    margin: '0 5vw 0 auto',
  },
};

const NavBar = ({ children }) => (
  <div style={styles.bannerContainer} >
    <div style={styles.logo}>
      <Icon
        imgUrl={logoImgUrl}
        href="/"
        altText="maverick logo"
      />
    </div>
    <div style={styles.navContainer}>
      { children }
    </div>
  </div>
);

NavBar.propTypes = {
  children: PropTypes.oneOfType([PropTypes.node, PropTypes.arrayOf(PropTypes.node)]).isRequired,
};

export default NavBar;
