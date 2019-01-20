/* eslint import/first: 0 */
import React from 'react';
import axios from 'axios';
import PropTypes from 'prop-types';
import config from '../../utils/config';
import BasicPage from '../../layouts/BasicPage';
import LoadingIcon from '../../components/icons/Loading';
import metaSliderHtml from './metaSlider';

const createMarkup = html => ({ __html: html });

const CmsPage = ({
  title, content, loading, error,
}) => {
  let mainContent = content;

  // Force all external content over https
  mainContent = mainContent.replace(/http:\/\//g, 'https://');

  // Add metaSlider css & js inline
  if (mainContent.includes('metaslider')) {
    mainContent += metaSliderHtml;
  }

  return (
    <div>
      <BasicPage title={title}>
        {error && <div>{error}</div>}
        {loading && <LoadingIcon />}
        {content && <div dangerouslySetInnerHTML={createMarkup(mainContent)} />}
      </BasicPage>
    </div>
  );
};

CmsPage.getInitialProps = async ({ query }) => {
  try {
    const { slug } = query;
    const url = `${config.maverickCms.url}/pages/?slug=${slug}&per_page=1`;
    const res = await axios(url);

    // no matching pages in wordpress
    if (res.data.length < 1) {
      return {
        loading: false,
        loaded: true,
        title: 'Error',
        error: `No content foundat /pages/${slug}`,
      };
    }

    // content returned from wordpress
    const data = res.data.shift();
    return {
      content: data.content.rendered,
      title: data.title.rendered,
      loading: false,
      loaded: true,
      error: false,
    };
  } catch (error) {
    return { content: '', loading: false, error: error.toString() };
  }
};

CmsPage.propTypes = {
  title: PropTypes.string,
  content: PropTypes.string,
  loading: PropTypes.bool,
  query: PropTypes.object, // eslint-disable-line react/no-unused-prop-types
  error: PropTypes.oneOfType([PropTypes.bool, PropTypes.string]),
};

CmsPage.defaultProps = {
  title: '',
  content: '',
  loading: true,
  query: { slug: null },
  error: false,
};

export default CmsPage;
