/* eslint import/first: 0 */
import React from 'react';
import Radium from 'radium';
// import PropTypes from 'prop-types';
import P from '../common/P';
import A from '../common/A';
import AppStoreImage from '../../assets/images/apple-store-black.png';
import { mediumBreakpoint, largeBreakpoint } from '../../assets/breakpoints';
// import Link from '../../routes';
import { berry } from '../../assets/colors';

const styles = {
  wrapper: {
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'flex-start',
    flexWrap: 'nowrap',
    marginTop: 40,
    [largeBreakpoint]: {
      flexDirection: 'row',
      alignItems: 'flex-start',
    },
  },
  buttonWrapper: {
    marginBottom: 20,
    [mediumBreakpoint]: {
      marginRight: 22,
    },
  },
  button: {
    maxWidth: 180,
  },
};

const DownloadAppBlock = () => (
  <section style={styles.wrapper}>
    <section style={styles.buttonWrapper}>
      <A href="https://itunes.apple.com/us/app/maverick-do-your-thing/id1301478918">
        <img src={AppStoreImage} alt="Download on the App Store" style={styles.button} />
      </A>
    </section>
    <section>
      <P first fontWeight="500">
        Take the challenge by downloading the mobile Maverick app for iOS, then you can do your
        thing from anywhere!
      </P>
      <P>
        Or you can <A route="/get-started" color={berry}>sign up</A> for the web app.
      </P>
    </section>
  </section>
);
DownloadAppBlock.propTypes = {};

DownloadAppBlock.defaultProps = {};

export default Radium(DownloadAppBlock);
