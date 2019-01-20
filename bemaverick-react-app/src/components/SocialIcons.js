import React from 'react';
import Icon from './Icon';

import youtubeImgUrl from '../assets/images/social-icon-youtube.png';
import instagramImgUrl from '../assets/images/social-icon-instagram.png';
import facebookImgUrl from '../assets/images/social-icon-facebook.png';
import twitterImgUrl from '../assets/images/social-icon-twitter.png';

const styles = {
  socialContainer: {
    display: 'flex',
    justifyContent: 'space-between',
    width: '210px',
  },
};

export default () => (
  <div style={styles.socialContainer}>
    <Icon
      imgUrl={youtubeImgUrl}
      href="https://www.youtube.com/c/GenMaverick"
      altText="Maverick Youtube"
    />
    <Icon
      imgUrl={instagramImgUrl}
      href="https://www.instagram.com/genmaverick/"
      altText="Maverick Instagram"
    />
    <Icon
      imgUrl={facebookImgUrl}
      href="https://www.facebook.com/genmaverick"
      altText="Maverick Facebook"
    />
    <Icon
      imgUrl={twitterImgUrl}
      href="https://twitter.com/genmaverick"
      altText="Maverick Twitter"
    />
  </div>
);
