import React from 'react';
import PropTypes from 'prop-types';
import { Field, reduxForm } from 'redux-form';
import TextField from '../../fields/TextField';
import Checkbox from '../../fields/Checkbox';
import Button from '../../fields/Button';
import Loading from '../../icons/Loading';
import submit from './submit';
import validate from './validate';

const styles = {
  formContainer: {
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center',
  },
};

const SignupMaverickStep1 = ({ ...props }) => {
  const { handleSubmit, /* pristine, reset, */ submitting, error } = props;
  return (
    <div style={styles.formContainer}>
      <form onSubmit={handleSubmit(submit)} autoComplete="off">
        <div style={styles.formContainer}>
          {/* <input />
          <input type="password" /> */}
          <Field
            name="username"
            component={TextField}
            label="Create username"
            fullWidth
            autoComplete="off"
          />
          <Field
            name="password"
            component={TextField}
            label="Create password"
            fullWidth
            type="password"
            autoComplete="new-password"
          />
          <Field
            name="accept"
            component={Checkbox}
            value
            label="By signing up you accept the Maverick Terms of Service & Privacy Policy"
            color={styles.formColor}
            margin="15px 0 0 0"
            lineHeight="1.4"
          />
          <Button
            type="submit"
            label="Sign Up"
            primary
            width="200px"
            margin="15px 0 10px 0"
            disabled={submitting}
          />
          {submitting && <Loading width={30} />}
          {error && !submitting && <div style={{ color: 'red' }}>{error}</div>}
        </div>
      </form>
    </div>
  );
};

SignupMaverickStep1.propTypes = {
  handleSubmit: PropTypes.func,
  pristine: PropTypes.bool,
  // reset: PropTypes.func,
  submitting: PropTypes.bool,
  error: PropTypes.oneOfType([PropTypes.string, PropTypes.object]),
};

SignupMaverickStep1.defaultProps = {
  handleSubmit: () => {},
  pristine: true,
  // reset: () => {},
  submitting: false,
  error: '',
};

export default reduxForm({
  form: 'SignupMaverickStep1', // a unique identifier for this form
  validate,
  // asyncValidate,
})(SignupMaverickStep1);
