/* eslint import/first: 0 */
import React from 'react';
import PropTypes from 'prop-types';
import CommentsButton from '../CommentsButton';
import ResponsesButton from '../ResponsesButton';

// TODO: implement mediaQueries w/ Radium
// https://github.com/FormidableLabs/radium/tree/master/docs/guides#media-queries

const styles = {
  wrapper: {
    // border: '1px solid blue',
  },
};

const ActivityIndicator = ({ comments, responses }) => (
  <section style={styles.wrapper}>
    {comments > 0 && <CommentsButton total={comments} href="/get-started" />}
    {responses > 0 && <ResponsesButton total={responses} href="/get-started" />}
  </section>
);
ActivityIndicator.propTypes = {
  comments: PropTypes.number,
  responses: PropTypes.number,
};

ActivityIndicator.defaultProps = {
  comments: 0,
  responses: 0,
};

export default ActivityIndicator;
