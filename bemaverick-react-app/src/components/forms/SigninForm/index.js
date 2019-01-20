import React from "react";
import PropTypes from "prop-types";
import { Field, reduxForm } from "redux-form";
import TextField from "../../fields/TextField";
import Button from "../../fields/Button";
import Loading from "../../icons/Loading";
import submit from "./submit";
import validate from "./validate";
import A from "../../common/A";
import FadeInUp from "../../Animation/FadeInUp";
import { berry, berryLight } from "../../../assets/colors";

const styles = {
  formContainer: {
    display: "flex",
    flexDirection: "column",
    alignItems: "center"
  },
  submit: {
    marginTop: 20,
    width: "100%",
    height: 50
  }
};

const SigninForm = ({ ...props }) => {
  const {
    handleSubmit,
    /* pristine, /* reset, */ submitting,
    error,
    theme,
    usernameProps
  } = props;
  const inputTextColor = theme === "dark" ? "#ffffff" : "#333333";
  return (
    <form onSubmit={handleSubmit(submit)}>
      <FadeInUp>
        <section>
          <Field
            name="username"
            component={TextField}
            color={inputTextColor}
            label="Enter your username"
            fullWidth
            {...usernameProps}
            autoComplete="off"
          />
        </section>
        <section>
          <Field
            name="password"
            component={TextField}
            label="Enter your password"
            color={inputTextColor}
            fullWidth
            type="password"
            autoComplete="new-password"
          />
        </section>
        <section>
          <Button
            type="submit"
            label="Sign In"
            width="100%"
            backgroundColor={berry}
            hoverColor={berryLight}
            style={styles.submit}
            primary
            disabled={submitting}
          />
        </section>
        <section>
          {submitting && <Loading width={30} />}
          {error && !submitting && <div style={{ color: "red" }}>{error}</div>}
          <A href="/auth/password-forgot" fontSize="13px" margin="15px 0 0 0">
            Forgot Password?
          </A>
        </section>
      </FadeInUp>
    </form>
  );
};

SigninForm.propTypes = {
  handleSubmit: PropTypes.func,
  pristine: PropTypes.bool,
  // reset: PropTypes.func,
  submitting: PropTypes.bool,
  error: PropTypes.oneOfType([PropTypes.string, PropTypes.object]),
  theme: PropTypes.string,
  usernameProps: PropTypes.object
};

SigninForm.defaultProps = {
  handleSubmit: () => {},
  pristine: true,
  // reset: () => {},
  submitting: false,
  error: "",
  theme: "default",
  usernameProps: {}
};

export default reduxForm({
  form: "SigninForm", // a unique identifier for this form
  validate
  // asyncValidate,
})(SigninForm);
