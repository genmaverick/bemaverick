import React from 'react';
import PropTypes from 'prop-types';

const defaultStyles = {
  fontSize: '30pt',
  lineHeight: '36pt',
  fontWeight: 'normal',
  margin: '30px 0',
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
