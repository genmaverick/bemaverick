import React from 'react';
import PropTypes from 'prop-types';
import MaterialUIDatePicker from 'material-ui/DatePicker';
import { white, black, textLight, textDark, borderLightest } from '../../assets/colors';

const styles = {
  datePicker: {
    width: '100%',
  },
  textField: {
    width: '100%',
    height: 50,
    marginBottom: 30,
    marginTop: 10,
    background: white,
  },
  input: {
    fontWeight: '300',
    fontSize: '16pt',
    color: textDark,
    padding: '0 20px 0 20px',
    marginTop: 0,
    border: `1px solid ${borderLightest}`,
    boxShadow: `inset 0px 0px 3px ${borderLightest}`,
  },
  error: { bottom: 0 },
  hint: {},
  underline: { bottom: 0 },
  floatingLabel: {
    fontWeight: '300',
    fontSize: '14pt',
    color: textDark,
    padding: '0 20px 0 20px',
    marginTop: 0,
    top: 14,
    whiteSpace: 'nowrap',
    overflow: 'hidden',
  },
  floatingLabelShrink: {
    top: 5,
  },
};

const DatePicker = ({
  input, label, meta: { touched, error }, onChange, color, ...custom
}) => (
  <MaterialUIDatePicker
    hintText={label}
    floatingLabelText={label}
    errorText={touched && error}
    {...input}
    {...custom}
    style={{ ...styles.datePicker }}
    textFieldStyle={{ ...styles.textField }}
    inputStyle={{ ...styles.input }}
    errorStyle={{ ...styles.error }}
    hintStyle={{ ...styles.hint }}
    underlineStyle={{ ...styles.underline }}
    floatingLabelStyle={{ ...styles.floatingLabel }}
    floatingLabelShrinkStyle={{ ...styles.floatingLabelShrink }}
    onChange={(event, value) => {
      input.onChange(value);
      if (onChange) {
        onChange(value);
      }
    }}
  />
);

DatePicker.propTypes = {
  input: PropTypes.object,
  label: PropTypes.string,
  meta: PropTypes.shape({
    touched: PropTypes.bool,
    error: PropTypes.oneOfType([PropTypes.string, PropTypes.object]),
  }),
  color: PropTypes.string,
  custom: PropTypes.object,
  onChange: PropTypes.oneOfType([PropTypes.func, PropTypes.bool]),
};

DatePicker.defaultProps = {
  input: {},
  label: '',
  color: '#000000',
  meta: { touched: false, error: '' },
  custom: {},
  onChange: false,
};

export default DatePicker;
