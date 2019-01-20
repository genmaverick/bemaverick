import React from 'react';
import PropTypes from 'prop-types';
import FlatButton from 'material-ui/FlatButton';
import { textDark } from '../../assets/colors';

const styles = {
  button: {
    padding: '0 25px 0 25px',
    minHeight: 40,
    fontWeight: 'normal',
  },
  default: {
    border: `1px solid ${textDark}`,
    color: textDark,
  },
};

const Button = ({ label, type, ...props }) => (
  <FlatButton label={label} style={{ ...styles.button, ...styles[type] }} {...props} />
);

Button.propTypes = {
  label: PropTypes.string.isRequired,
  type: PropTypes.string,
};

Button.defaultProps = {
  type: 'default',
};

export default Button;
