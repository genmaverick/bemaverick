import { SubmissionError, reset } from 'redux-form';
import Maverick from '../../../utils/maverick';

const sleep = ms => new Promise(resolve => setTimeout(resolve, ms));
const delay = 0;

const submit = (values, dispatch) =>
  sleep(delay).then(async () => {
    // simulate server latency
    const {
      name, email, username, message,
    } = values;
    try {
      // Send the message to zendesk
      const response = await Maverick.zendesk({
        name,
        email,
        username,
        message,
      });
      if (response.status === 200) {
        // Clear the form
        dispatch(reset('ContactForm')); // requires form name
      }
      if (response.status >= 400) {
        throw new SubmissionError({
          _error:
            response.data.errors[0].message || 'Could not send message, please try again later.',
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
