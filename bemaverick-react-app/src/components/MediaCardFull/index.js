/* eslint-disable jsx-a11y/media-has-caption */
import React from 'react';
import PropTypes from 'prop-types';
import Radium from 'radium';
// import { borderLight } from '../../assets/colors';
import { mediumBreakpoint } from '../../assets/breakpoints';

const styles = {
  card: {
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'flex-start',
    [mediumBreakpoint]: {
      padding: '40px 0 30px 40px',
      margin: '20px 0 20px 0',
      flexDirection: 'row-reverse',
      position: 'relative',
    },
  },
  cardBackground: {
    [mediumBreakpoint]: {
      background: '#fff',
      position: 'absolute',
      top: 0,
      left: 0,
      width: '80%',
      height: '100%',
      zIndex: 1,
    },
  },
  content: {
    height: '100%',
    flexGrow: 1,
    padding: '30px 25px',
    zIndex: 2,
    background: '#fff',
    [mediumBreakpoint]: {
      background: 'transparent',
      padding: '0 50px 0 0',
    },
  },
  media: {
    maxWidth: '100%',
    padding: 0,
    // background: '#efefef',
    zIndex: 3,
    [mediumBreakpoint]: {
      width: 350,
    },
    flexShrink: 0,
  },
  image: {
    width: 'auto',
    maxWidth: '100%',
  },
  video: {
    width: 'auto',
    maxWidth: '100%',
  },
};

const MediaCardFull = ({ children, image, video }) => (
  <section style={styles.card}>
    {video && (
      <section style={styles.media}>
        <video
          // width="350"
          //  height="467"
          controls
          style={styles.video}
          poster={image}
        >
          <source src={video} type="video/mp4" />
        </video>
      </section>
    )}
    {!video &&
      image && (
        <section style={styles.media}>
          <img src={image} style={styles.image} alt="Challenge" />
        </section>
      )}
    <section style={styles.content}>{children}</section>
    <section style={styles.cardBackground}>&nbsp;</section>
  </section>
);

MediaCardFull.propTypes = {
  children: PropTypes.oneOf([PropTypes.node, PropTypes.arrayOf([PropTypes.node])]),
  image: PropTypes.string,
  video: PropTypes.oneOfType([PropTypes.string, PropTypes.bool]),
};

MediaCardFull.defaultProps = {
  children: null,
  image: false,
  video: false,
};

export default Radium(MediaCardFull);
