import React from "react";
import PropTypes from "prop-types";
import MaterialUITextField from "material-ui/TextField";
import InputMask from "react-input-mask";
import {
  white,
  black,
  textLight,
  textDark,
  borderLightest
} from "../../assets/colors";

const styles = {
  textField: {
    height: 50,
    marginBottom: 22,
    marginTop: 10,
    background: white
  },
  input: {
    fontWeight: "300",
    fontSize: "16pt",
    color: textDark,
    padding: "0 20px 0 20px",
    marginTop: 0,
    border: `1px solid ${borderLightest}`,
    boxShadow: `inset 0px 0px 3px ${borderLightest}`
  },
  error: { bottom: 0 },
  hint: {
    fontWeight: "300",
    fontSize: "16pt",
    color: textLight,
    padding: "0 20px 0 20px"
  },
  underline: { bottom: 0 },
  floatingLabel: {
    fontWeight: "300",
    fontSize: "14pt",
    color: textDark,
    padding: "0 20px 0 20px",
    marginTop: 0,
    top: 14,
    whiteSpace: "nowrap",
    overflow: "hidden"
  },
  floatingLabelShrink: {
    top: 5
  }
};

const TextField = ({
  input,
  label,
  hintText,
  color,
  margin,
  meta: { touched, error },
  ...custom
}) => (
  <MaterialUITextField
    hintText={hintText}
    floatingLabelText={label}
    errorText={touched && error}
    {...input}
    {...custom}
    style={{ ...styles.textField }}
    inputStyle={{ ...styles.input }}
    errorStyle={{ ...styles.error }}
    hintStyle={{ ...styles.hint }}
    underlineStyle={{ ...styles.underline }}
    floatingLabelStyle={{ ...styles.floatingLabel }}
    floatingLabelShrinkStyle={{ ...styles.floatingLabelShrink }}
    // autoComplete="off"
  />
);

TextField.propTypes = {
  input: PropTypes.object,
  label: PropTypes.string,
  hintText: PropTypes.string,
  color: PropTypes.string,
  margin: PropTypes.string,
  meta: PropTypes.shape({
    touched: PropTypes.bool,
    error: PropTypes.oneOfType([PropTypes.string, PropTypes.object])
  }),
  custom: PropTypes.object
};

TextField.defaultProps = {
  input: {},
  label: "",
  hintText: "",
  color: "#000000",
  margin: "0px",
  meta: { touched: false, error: "" },
  custom: {}
};

export default TextField;
