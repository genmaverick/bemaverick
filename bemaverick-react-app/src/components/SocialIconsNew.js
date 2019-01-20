import React from 'react';
import A from './common/A/index';
import YoutubeIcon from './icons/YoutubeIcon';
import InstagramIcon from './icons/InstagramIcon';
import TwitterIcon from './icons/TwitterIcon';
import FacebookIcon from './icons/FacebookIcon';

const styles = {
  socialContainer: {
    display: 'flex',
    justifyContent: 'space-between',
    width: '150px',
  },
  icon: {
    height: '30px',
    width: '30px',
  },
};

export default () => (
  <div style={styles.socialContainer}>
    <A href="https://www.youtube.com/c/GenMaverick"><YoutubeIcon style={styles.icon} /></A>
    <A href="https://www.instagram.com/genmaverick/"><InstagramIcon style={styles.icon} /></A>
    <A href="https://www.facebook.com/genmaverick"><FacebookIcon style={styles.icon} /></A>
    <A href="https://twitter.com/genmaverick"><TwitterIcon style={styles.icon} /></A>
  </div>
);
