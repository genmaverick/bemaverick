import React from 'react';
import PropTypes from 'prop-types';
import appStoreImg from '../../assets/images/apple-store-black.png';

const AppleStore = ({ margin, width }) => (
  <a href="https://itunes.apple.com/us/app/maverick-do-your-thing/id1301478918?mt=8">
    <img src={appStoreImg} style={{ ...margin, width }} alt="apple-store" />
  </a>
);

const styleShape = {
  margin: PropTypes.string.isRequired,
};

AppleStore.propTypes = {
  width: PropTypes.string,
  margin: PropTypes.shape(styleShape).isRequired,
};

AppleStore.defaultProps = {
  width: '150px',
};

export default AppleStore;

