/* eslint import/first: 0 */
import React from 'react';
import axios from 'axios';
import PropTypes from 'prop-types';
import config from '../../utils/config';
import BasicPage from '../../layouts/BasicPage';
import LoadingIcon from '../../components/icons/Loading';

const createMarkup = html => ({ __html: html });

// const sleep = ms => new Promise(resolve => setTimeout(resolve, ms));

const TermsOfService = ({ content, loading, error }) => (
  <div>
    <BasicPage title="Copyright">
      {error && <div>{error}</div>}
      {loading && <LoadingIcon />}
      {content && <div dangerouslySetInnerHTML={createMarkup(content)} />}
    </BasicPage>
  </div>
);

TermsOfService.getInitialProps = async () => {
  try {
    const res = await axios(`${config.maverickCms.url}/pages/14`);
    // await sleep(3000);
    return { content: res.data.content.rendered, loading: false, error: false };
  } catch (error) {
    return { content: '', loading: false, error: error.toString() };
  }
};

TermsOfService.propTypes = {
  content: PropTypes.string,
  loading: PropTypes.bool,
  error: PropTypes.oneOfType([PropTypes.bool, PropTypes.string]),
};

TermsOfService.defaultProps = {
  content: '',
  loading: true,
  error: false,
};

export default TermsOfService;
