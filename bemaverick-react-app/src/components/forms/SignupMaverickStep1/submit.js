import { SubmissionError } from 'redux-form';
import { Router } from '../../../routes';
import Maverick from '../../../utils/maverick';
import { setValidatedUsername } from '../../../containers/App/actions';

const sleep = ms => new Promise(resolve => setTimeout(resolve, ms));
const delay = 0;

const submit = (values, dispatch) =>
  sleep(delay).then(async () => {
    // simulate server latency
    const { username, password } = values;
    try {
      const response = await Maverick.validateUsername(username);
      if (response.status === 200) {
        dispatch(setValidatedUsername(username, password));
        Router.pushRoute('/signup').then(() => {
          const top = 350; // Top of the SignupMaverickStep2 form
          // eslint-disable-next-line no-undef
          window.scrollTo({
            top,
            behavior: 'smooth',
          });
        });
      }
      if (response.status >= 400) {
        throw new SubmissionError({
          _error: response.data.errors[0].message || 'Username unavailable.',
        });
      }
    } catch (error) {
      throw error.errors && error.errors._error // eslint-disable-line no-underscore-dangle
        ? error
        : new SubmissionError({
          _error: 'Unknown error, please try again later.',
        });
    }
  });

export default submit;
