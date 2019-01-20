import React from 'react';
import PropTypes from 'prop-types';
import MaterialUIFlatButton from 'material-ui/FlatButton';

const styles = {
  button: {
    display: 'flex',
    justifyContent: 'center',
    alignItems: 'center',
    width: 100,
    height: 50,
    borderRadius: '20px',
  },
  label: {
    fontSize: 18,
    fontWeight: 500,
    textTransform: 'uppercase',
    textDecoration: 'none',
    letterSpacing: 1,
    color: '#ffffff',
  },
};

const Button = ({
  label, type, width, margin, ...custom, disabled,
}) =>
  // const backgroundColor = !disabled ? '#00B0AC' : '#cccccc';
  // const hoverColor = !disabled ? '#00cac5' : '#cccccc';
  // styles.label.color = !disabled ? '#ffffff' : '#cccccc';
  // console.log('style', style);
  (
    <MaterialUIFlatButton
      style={{ ...styles.button, width, margin }}
      type={type}
      // backgroundColor={backgroundColor}
      // hoverColor={hoverColor}
      {...custom}
    >
      <span style={styles.label}>{label}</span>
    </MaterialUIFlatButton>
  );
Button.propTypes = {
  label: PropTypes.string.isRequired,
  type: PropTypes.string,
  width: PropTypes.string,
  margin: PropTypes.string,
  custom: PropTypes.object,
  disabled: PropTypes.bool,
};

Button.defaultProps = {
  type: 'button',
  width: '200px',
  margin: '0',
  custom: {},
  disabled: false,
};

export default Button;
