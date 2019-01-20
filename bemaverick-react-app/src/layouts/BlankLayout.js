import React from 'react';
import PropTypes from 'prop-types';
import Radium from 'radium';
import App from '../containers/App';
import Meta from '../components/Meta';
import { pinkBackgroundLight } from '../assets/colors';
// import { mediumBreakpoint, largeBreakpoint } from '../assets/breakpoints';

const styles = {
  layout: {
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'stretch',
    background: pinkBackgroundLight,
    minHeight: '100vh',
    // [mediumBreakpoint]: {},
    // [largeBreakpoint]: {},
  },
};

const BlankLayout = ({ title, children, style }) => (
  <App>
    <div style={{ ...styles.layout, ...style }}>
      <Meta title={title} />
      {children}
    </div>
  </App>
);

BlankLayout.propTypes = {
  title: PropTypes.string.isRequired,
  children: PropTypes.oneOfType([PropTypes.node, PropTypes.arrayOf(PropTypes.node)]).isRequired,
  style: PropTypes.object,
};

BlankLayout.defaultProps = {
  style: {},
};

export default Radium(BlankLayout);
