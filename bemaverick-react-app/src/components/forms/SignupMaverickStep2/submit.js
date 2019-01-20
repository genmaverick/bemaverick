import { SubmissionError } from 'redux-form';
// import { Router } from '../../../routes';
import Maverick from '../../../utils/maverick';
import { setValidatedUsername } from '../../../containers/App/actions';
import Leanplum from '../../../utils/leanplum';

const sleep = ms => new Promise(resolve => setTimeout(resolve, ms));
const delay = 0;

const submit = (values, dispatch) =>
  sleep(delay).then(async () => {
    // const { username, password } = values;
    try {
      const response = await Maverick.registerKid(values);
      if (response.status === 200) {
        // console.log('Signup successful!');
        // Clear validated user
        dispatch(setValidatedUsername(false, false));
        // Redirect
        window.location.href = '/'; // eslint-disable-line no-undef
        Leanplum.track('WEB:SIGNUP:SUCCESS');
      }
      if (response.status >= 400) {
        Leanplum.track('WEB:SIGNUP:ERROR', { response: response.data });
        throw new SubmissionError({
          _error: response.data.errors[0].message || 'Signup error.',
        });
      }
    } catch (error) {
      Leanplum.track('WEB:SIGNUP:ERROR', { error: error.errors });
      throw error.errors && error.errors._error // eslint-disable-line no-underscore-dangle
        ? error
        : new SubmissionError({
          _error: 'Unknown error, please try again later.',
        });
    }
  });

export default submit;
