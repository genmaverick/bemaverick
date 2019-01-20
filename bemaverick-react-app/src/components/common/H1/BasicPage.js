import React from 'react';
import PropTypes from 'prop-types';

const styleH1 = {
  fontSize: '5vh',
  fontStyle: 'italic',
  fontWeight: 600,
  textTransform: 'uppercase',
  color: '#F1495B',
  margin: 0,
};

const H1 = ({ children }) => {
  const combinedStyle = { ...styleH1 };
  return <h1 style={combinedStyle}>{children}</h1>;
};

H1.propTypes = {
  children: PropTypes.oneOfType([PropTypes.node, PropTypes.arrayOf(PropTypes.node)]).isRequired,
};

export default H1;
