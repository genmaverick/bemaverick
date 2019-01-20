import React from 'react';
import Radium from 'radium';
import { mediumBreakpoint } from '../../assets/breakpoints';
import A from '../common/A/navigation';
import SocialIcons from '.././SocialIconsNew';
import { pinkBackgroundDark } from '../../assets/colors';

const styles = {
  footerContainer: {
    display: 'flex',
    flexDirection: 'column',
    justifyContent: 'center',
    alignItems: 'center',
    padding: '50px 120px 50px 120px',
    background: pinkBackgroundDark,
    [mediumBreakpoint]: {
      flexDirection: 'row',
      alignItems: 'flex-start',
      justifyContent: 'space-between',
    },
  },
  linkContainer: {
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center',
    [mediumBreakpoint]: {
      alignItems: 'flex-start',
    },
  },
  emptyContainer: {
    width: '23%',
  },
};

const Footer = () => (
  <div style={styles.footerContainer}>
    <div style={styles.linkContainer}>
      <A href="/faq" footer>FAQs</A>
      <A href="/terms-of-service" footer>Terms of Service</A>
      <A href="/privacy-policy" footer>Privacy Policy</A>
    </div>
    <div style={styles.linkContainer}>
      <A href="/contact" footer>Contact Us</A>
      <A href="/copyright" footer>Copyright</A>
    </div>
    <div style={styles.emptyContainer} />
    <SocialIcons />
  </div>
);

export default Radium(Footer);
