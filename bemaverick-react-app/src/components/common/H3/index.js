import React from 'react';
import PropTypes from 'prop-types';

const styleH1 = {
  fontSize: '24',
  fontWeight: 500,
  textTransform: 'uppercase',
  color: '#000000',
  margin: '30px 0 30px 0',
};

const H3 = ({ children }) => {
  const combinedStyle = { ...styleH1 };
  return <h3 style={combinedStyle}>{children}</h3>;
};

H3.propTypes = {
  children: PropTypes.oneOfType([PropTypes.node, PropTypes.arrayOf(PropTypes.node)]).isRequired,
};

export default H3;
