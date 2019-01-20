import React from 'react';
import PropTypes from 'prop-types';
import Radium from 'radium';
import { white } from '../../assets/colors';
import { smallBreakpoint, mediumBreakpoint, largeBreakpoint } from '../../assets/breakpoints';
import brushBackground from '../../assets/images/brush-large.png';

const styles = {
  border: {
    zIndex: 0,
    border: `5px solid ${white}`,
    flexShrink: 0,
    flexGrow: 1,
    margin: 10,
    position: 'relative',
    display: 'flex',
    flexDirection: 'column',
    justifyContent: 'center',
    [smallBreakpoint]: {
      margin: 30,
    },
    [mediumBreakpoint]: {
      margin: 60,
    },
    [largeBreakpoint]: {
      margin: 90,
    },
  },
  background: {
    display: 'none',
    [mediumBreakpoint]: {
      display: 'block',
      position: 'absolute',
      zIndex: -1,
      left: '50%',
      top: '50%',
      transform: 'translate(-40%, -50%)',
      width: 437,
      height: 578,
      maxWidth: '90%',
      maxHeight: '90%',
      backgroundImage: `url(${brushBackground})`,
    },
  },
  children: {
    zIndex: 2,
  },
};

const Border = ({ children, style }) => {
  const combinedStyle = { ...styles.border, ...style };
  return (
    <div style={combinedStyle}>
      <div style={styles.background} alt="Brush Stroke" />
      <div style={styles.children}>{children}</div>
    </div>
  );
};

Border.propTypes = {
  children: PropTypes.oneOfType([PropTypes.node, PropTypes.arrayOf(PropTypes.node)]).isRequired,
  style: PropTypes.object,
};

Border.defaultProps = {
  style: {},
};

export default Radium(Border);
