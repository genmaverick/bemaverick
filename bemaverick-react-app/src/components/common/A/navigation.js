import React from 'react';
import PropTypes from 'prop-types';
import Radium from 'radium';
import { mediumBreakpoint } from '../../../assets/breakpoints';
import { Link } from '../../../routes';
import { textDark } from '../../../assets/colors';

const styles = {
  navigation: {
    textDecoration: 'none',
    textTransform: 'uppercase',
    color: '#000000',
  },
  header: {
    fontSize: '16px',
    margin: '0 0 0 28px',
  },
  footer: {
    margin: '0 0 30px 0',
    fontSize: '12px',
    fontWeight: 500,
    letterSpacing: '1px',
    color: textDark,
    [mediumBreakpoint]: {
      margin: '5px 0 5px 0',
    },
  },
};

const A = ({
  header, footer, href, route, children,
}) => {
  let style = styles.navigation;
  style = header ? { ...style, ...styles.header } : style;
  style = footer ? { ...style, ...styles.footer } : style;

  if (route !== '') {
    return (
      <Link route={route}>
        <a style={style}> {children} </a>
      </Link>
    );
  }
  return (
    <a href={href} style={style}> {children} </a>
  );
};

A.propTypes = {
  header: PropTypes.bool,
  footer: PropTypes.bool,
  href: PropTypes.string,
  route: PropTypes.string,
  children: PropTypes.oneOfType([PropTypes.node, PropTypes.arrayOf(PropTypes.node)]).isRequired,
};

A.defaultProps = {
  header: false,
  footer: false,
  href: '',
  route: '',
};

export default Radium(A);
