import React from 'react';
import TextField from 'material-ui/TextField';
import FormButton from './FormButton';

const styles = {
  formContainer: {
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center',
  },
  inputText: {
    fontWeight: '300',
    color: '#ffffff',
  },
  inputField: {
    margin: '10% 0 0 0',
  },
  checkboxText: {
    fontFamily: 'Barlow, sans-serif',
    fontSize: '13px',
    fontWeight: '200',
    lineHeight: 1.4,
    color: '#ffffff',
  },
  buttonWidth: {
    width: '200px',
    margin: '15% 0 0 0',
  },
};

export default () => (
  <div style={styles.formContainer}>
    <div>
      <TextField
        hintText="Enter your email"
        fullWidth
        hintStyle={styles.inputText}
        inputStyle={styles.inputText}
        style={styles.inputField}
      />
      <TextField
        hintText="Enter your password"
        fullWidth
        type="password"
        hintStyle={styles.inputText}
        inputStyle={styles.inputText}
        style={styles.inputField}
      />
    </div>
    <FormButton buttonName="Sign In" buttonUrl="/" widthObj={styles.buttonWidth} />
  </div>
);
