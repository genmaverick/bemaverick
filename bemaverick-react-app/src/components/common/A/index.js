import React from 'react';
import PropTypes from 'prop-types';
import { Link } from '../../../routes';

const styleA = {
  textDecoration: 'none',
};

const A = ({
  href, route, children, fontSize, color, margin,
}) => {
  // combine styles
  const combinedStyle = (fontSize !== '0') ? {
    ...styleA, margin, fontSize, color,
  } : { ...styleA, margin, color };

  if (route !== '') {
    return (
      <Link route={route}>
        <a style={combinedStyle}> {children} </a>
      </Link>
    );
  }
  return (
    <a href={href} style={combinedStyle}> {children} </a>
  );
};

A.propTypes = {
  href: PropTypes.string,
  route: PropTypes.string,
  fontSize: PropTypes.string,
  color: PropTypes.string,
  margin: PropTypes.string,
  children: PropTypes.oneOfType([PropTypes.node, PropTypes.arrayOf(PropTypes.node)]).isRequired,
};

A.defaultProps = {
  route: '',
  href: '',
  fontSize: '0',
  color: '#00B0AC',
  margin: '0',
};

export default A;
