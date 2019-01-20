import React from 'react';
import AppStoreImage from '../../assets/images/apple-store-black.png';

const styles = {
  button: {
    maxWidth: 180,
  },
};

const AppStoreButton = () => (
  <a href="https://itunes.apple.com/us/app/maverick-do-your-thing/id1301478918">
    <img src={AppStoreImage} alt="Download on the App Store" style={styles.button} />
  </a>
);

export default AppStoreButton;
