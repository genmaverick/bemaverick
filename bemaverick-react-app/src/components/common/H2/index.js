import React from 'react';
import PropTypes from 'prop-types';

const styleH2 = {
  fontSize: '24px',
  textTransform: 'uppercase',
  fontStyle: 'italic',
  fontWeight: 500,
  color: '#00B0AC',
  margin: 0,
};

const H2 = ({ children }) => {
  const combinedStyle = { ...styleH2 };
  return <h1 style={combinedStyle}>{children}</h1>;
};

H2.propTypes = {
  children: PropTypes.oneOfType([PropTypes.node, PropTypes.arrayOf(PropTypes.node)]).isRequired,
};

export default H2;
