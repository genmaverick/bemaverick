import React from 'react';
import PropTypes from 'prop-types';
import { Field, reduxForm } from 'redux-form';
import TextField from '../../fields/TextField';
import Button from '../../fields/Button';
import Loading from '../../icons/Loading';
import submit from './submit';
import validate from './validate';

const styles = {
  formContainer: {
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center',
    marginBottom: 40,
  },
  textField: {
    margin: '15px 0 15px 0',
  },
  buttonWidth: {
    width: '270px',
    margin: '50px 0 40px 0',
  },
};

const ContactForm = ({ ...props }) => {
  const {
    handleSubmit,
    /* pristine, /* reset, */ submitting,
    error,
    widthObj,
    submitSucceeded,
  } = props;
  return (
    <form onSubmit={handleSubmit(submit)}>
      <div style={{ ...widthObj, ...styles.formContainer }}>
        <Field
          name="name"
          component={TextField}
          label="Your name"
          fullWidth
          style={styles.textField}
          autoComplete="off"
        />
        <Field
          name="email"
          component={TextField}
          label="Your email address"
          fullWidth
          style={styles.textField}
          autoComplete="off"
        />
        <Field
          name="username"
          component={TextField}
          label="Your username (optional)"
          fullWidth
          style={styles.textField}
          autoComplete="off"
        />
        <Field
          name="message"
          component={TextField}
          label="Message"
          fullWidth
          style={styles.textField}
          autoComplete="off"
          multiLine
          rows={1}
          rowsMax={4}
        />
        <Button
          type="submit"
          label="Submit"
          width="225px"
          margin="30px 0 0 0"
          primary
          disabled={submitting}
        />
        {submitting && <Loading width={30} />}
        {error && !submitting && <div style={{ color: 'red' }}>{error}</div>}
        {submitSucceeded && <div style={{ color: 'green' }}>Your message has been submitted!</div>}
      </div>
    </form>
  );
};

const styleShape = {
  width: PropTypes.string.isRequired,
  maxWidth: PropTypes.string.isRequired,
};

ContactForm.propTypes = {
  widthObj: PropTypes.shape(styleShape).isRequired,
};

ContactForm.propTypes = {
  handleSubmit: PropTypes.func,
  pristine: PropTypes.bool,
  // reset: PropTypes.func,
  submitting: PropTypes.bool,
  error: PropTypes.oneOfType([PropTypes.string, PropTypes.object]),
  usernameProps: PropTypes.object,
  submitSucceeded: PropTypes.bool,
};

ContactForm.defaultProps = {
  handleSubmit: () => {},
  pristine: true,
  // reset: () => {},
  submitting: false,
  error: '',
  usernameProps: {},
  submitSucceeded: false,
};

export default reduxForm({
  form: 'ContactForm', // a unique identifier for this form
  validate,
  // asyncValidate,
})(ContactForm);
