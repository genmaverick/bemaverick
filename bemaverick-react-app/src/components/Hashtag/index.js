import React from 'react';
import PropTypes from 'prop-types';
import { teal } from '../../assets/colors';

const styles = {
  hashtag: {
    color: teal,
  },
};

const Button = ({ name, ...props }) => (
  <span {...props} style={styles.hashtag}>
    #{name}
  </span>
);

Button.propTypes = {
  name: PropTypes.string.isRequired,
};

Button.defaultProps = {};

export default Button;
