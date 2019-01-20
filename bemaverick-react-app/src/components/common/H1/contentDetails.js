import React from 'react';
import PropTypes from 'prop-types';

const defaultStyles = {
  margin: '55px 0 -5px 0',
  fontSize: '23pt',
  letterSpacing: 4,
  fontWeight: '600',
  textTransform: 'uppercase',
};

const H1 = ({ children, style }) => {
  const combinedStyle = { ...defaultStyles, ...style };
  return <h1 style={combinedStyle}>{children}</h1>;
};

H1.propTypes = {
  children: PropTypes.oneOfType([PropTypes.node, PropTypes.arrayOf(PropTypes.node)]).isRequired,
  style: PropTypes.object,
};

H1.defaultProps = {
  style: {},
};

export default H1;
