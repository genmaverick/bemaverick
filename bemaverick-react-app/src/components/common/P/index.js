import React from 'react';
import PropTypes from 'prop-types';
import { textDark } from '../../../assets/colors';

const defaultStyles = {
  fontSize: '14px',
  lineHeight: '18px',
  margin: '20px 0 20px 0',
};

const P = ({
  children, first, large, color, fontWeight,
}) => {
  const styles = { ...defaultStyles, color, fontWeight };
  if (first) {
    styles.marginTop = '0px';
  }
  if (large) {
    styles.fontSize = '13pt';
    styles.lineHeight = '20pt';
  }
  return <p style={styles}>{children}</p>;
};

P.propTypes = {
  children: PropTypes.oneOfType([PropTypes.node, PropTypes.arrayOf(PropTypes.node)]).isRequired,
  first: PropTypes.bool,
  large: PropTypes.bool,
  color: PropTypes.string,
  fontWeight: PropTypes.string,
};

P.defaultProps = {
  first: false,
  large: false,
  color: textDark,
  fontWeight: 'normal',
};

export default P;
