/* eslint import/first: 0 */
import React from 'react';
import axios from 'axios';
import moment from 'moment';
import PropTypes from 'prop-types';
import config from '../../utils/config';
import BasicPage from '../../layouts/BasicPage';
import LoadingIcon from '../../components/icons/Loading';

const createMarkup = html => ({ __html: html });

const Post = ({
  title, content, date, loading, error,
}) => {
  const formattedDate = moment(date, 'YYYY-MM-DDTHH:mm:ssZ').toString();
  return (
    <div>
      <BasicPage title={title}>
        {error && <div>{error}</div>}
        {loading && <LoadingIcon />}
        {date && <div>{formattedDate}</div>}
        {content && <div dangerouslySetInnerHTML={createMarkup(content)} />}
      </BasicPage>
    </div>
  );
};

Post.getInitialProps = async ({ query }) => {
  try {
    const { slug } = query;
    const url = `${config.maverickCms.url}/posts/?slug=${slug}&per_page=1`;
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
      date: data.date,
      loading: false,
      loaded: true,
      error: false,
    };
  } catch (error) {
    return { content: '', loading: false, error: error.toString() };
  }
};

Post.propTypes = {
  title: PropTypes.string,
  date: PropTypes.string,
  content: PropTypes.string,
  loading: PropTypes.bool,
  query: PropTypes.object, // eslint-disable-line react/no-unused-prop-types
  error: PropTypes.oneOfType([PropTypes.bool, PropTypes.string]),
};

Post.defaultProps = {
  title: '',
  date: '',
  content: '',
  loading: true,
  query: { slug: null },
  error: false,
};

export default Post;
