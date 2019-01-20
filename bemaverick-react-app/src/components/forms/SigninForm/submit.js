/* eslint-disable no-undef */
import { SubmissionError } from 'redux-form';
import Maverick from '../../../utils/maverick';
import Leanplum from '../../../utils/leanplum';

const sleep = ms => new Promise(resolve => setTimeout(resolve, ms));
const delay = 0;

const submit = values =>
  sleep(delay).then(async () => {
    // simulate server latency
    const { username, password } = values;
    try {
      const response = await Maverick.signin(username, password);
      if (response.status === 200) {
        // TODO:
        // 1 - set cookie (Done in the API)
        // 2 - update redux store
        // 3 - redirect user
        window.location.href = '/'; // eslint-disable-line no-undef
        Leanplum.track('WEB:SIGNIN:SUCCESS');
      }
      if (response.status >= 400) {
        throw new SubmissionError({
          _error: response.data.errors[0].message || 'Login error!',
        });
      }
    } catch (error) {
      Leanplum.track('WEB:SIGNIN:ERROR', { error: error.errors });
      throw error.errors && error.errors._error // eslint-disable-line no-underscore-dangle
        ? error
        : new SubmissionError({
          _error: 'Unknown error, please try again later.',
        });
    }
  });

export default submit;
