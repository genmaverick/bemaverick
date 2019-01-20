import React from 'react';
import DatePicker from 'material-ui/DatePicker';
import TextField from 'material-ui/TextField';
import H2 from '../../components/common/H2';
import FormButton from './FormButton';

const styles = {
  formContainer: {
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center',
  },
  inputField: {
    margin: '25px 0 0 0',
  },
  buttonWidth: {
    width: '270px',
    margin: '35px 0 0 0',
  },
};

export default () => (
  <div style={styles.formContainer}>
    <div>
      <H2>What’s Your Birthday?</H2>
      <DatePicker hintText="2001-01-01" openToYearSelection style={styles.inputField} />
      <TextField hintText="Email address" fullWidth style={styles.inputField} />
      <FormButton buttonName="Submit" buttonUrl="/" widthObj={styles.buttonWidth} />
    </div>
  </div>
);
