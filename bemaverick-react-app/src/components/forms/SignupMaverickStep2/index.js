import React from "react";
import PropTypes from "prop-types";
import { connect } from "react-redux";
import { Field, reduxForm, formValueSelector } from "redux-form";
import FadeInUp from "../../../components/Animation/FadeInUp";
import TextField from "../../fields/TextField";
import DatePicker from "../../fields/DatePicker";
import Checkbox from "../../fields/Checkbox";
import Button from "../../fields/Button";
import Loading from "../../icons/Loading";
import { berry, berryLight } from "../../../assets/colors";
import submit from "./submit";
import validate from "./validate";
import normalizeDate from "../normalizeDate";
import { calculateAge } from "../../../utils";

const styles = {
  formContainer: {
    display: "flex",
    flexDirection: "column",
    alignItems: "stretch",
    justifyContent: "flex-start"
  },
  datePicker: {},
  fullWidth: { width: "100%" },
  submit: {
    marginTop: 20,
    width: "100%",
    height: 50
  }
};

const SignupMaverickStep2 = ({ ...props }) => {
  const {
    handleSubmit,
    /* pristine, reset, */ submitting,
    error,
    birthdate
  } = props;

  const age = calculateAge(birthdate);
  return (
    <div style={styles.formContainer}>
      <div style={styles.formContainer}>
        <form onSubmit={handleSubmit(submit)} autoComplete="off">
          <FadeInUp>
            <section>
              <Field
                name="username"
                component={TextField}
                label="Create username"
                fullWidth
                autoComplete="off"
              />
            </section>
            <section>
              <Field
                name="password"
                component={TextField}
                label="Create password"
                fullWidth
                type="password"
                autoComplete="new-password"
              />
            </section>
            <section>
              <Field
                name="birthdate"
                hintText="mm/dd/yyyy"
                component={TextField}
                label="Birthdate"
                style={styles.datePicker}
                fullWidth
                normalize={normalizeDate}
                // mask="99/99/9999"
              />
            </section>
            <section>
              {/* Under 13 */}
              {age !== null && age < 13 ? (
                <span>
                  <Field
                    name="parentEmailAddress"
                    component={TextField}
                    label="Parent email address"
                    fullWidth
                    autoComplete="off"
                  />
                  <small>
                    * Please provide parent or family member email address
                  </small>
                </span>
              ) : (
                /* 13 and older */ <Field
                  name="emailAddress"
                  component={TextField}
                  label="Email address"
                  margin="-20px 0 10px 0"
                  fullWidth
                  autoComplete="off"
                />
              )}
            </section>
            <section>
              <Field
                name="accept"
                component={Checkbox}
                value
                label="By signing up you accept the Maverick Terms of Service & Privacy Policy"
                margin="0 0 10px 0"
              />
            </section>
            <section>
              <Button
                type="submit"
                label="Sign Up"
                width="100%"
                backgroundColor={berry}
                hoverColor={berryLight}
                style={styles.submit}
                primary
                disabled={submitting}
              />
            </section>
          </FadeInUp>
          {submitting && <Loading width={30} />}
          {error &&
            !submitting && (
              <div style={{ color: "red", paddingTop: 20 }}>{error}</div>
            )}
        </form>
      </div>
    </div>
  );
};

SignupMaverickStep2.propTypes = {
  handleSubmit: PropTypes.func,
  pristine: PropTypes.bool,
  // reset: PropTypes.func,
  submitting: PropTypes.bool,
  error: PropTypes.oneOfType([PropTypes.string, PropTypes.object]),
  birthdate: PropTypes.oneOfType([PropTypes.string])
};

SignupMaverickStep2.defaultProps = {
  handleSubmit: () => {},
  pristine: true,
  // reset: () => {},
  submitting: false,
  error: "",
  birthdate: null
};

const selector = formValueSelector("SignupMaverickStep2"); // <-- same as form nameconst mapStateToProps = state => ({

const mapStateToProps = state => ({
  initialValues: {
    username: state.global.data.validated.username || "",
    password: state.global.data.validated.password || "",
    accept: state.global.data.validated.username ? true : null
  },
  birthdate: selector(state, "birthdate") || null
});

export default connect(mapStateToProps)(
  reduxForm({
    form: "SignupMaverickStep2", // a unique identifier for this form
    validate
    // asyncValidate,
  })(SignupMaverickStep2)
);
