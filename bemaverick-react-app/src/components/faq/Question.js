import React from 'react';
import PropTypes from 'prop-types';

const styles = {
  container: {
    marginBottom: '35px',
  },
  aText: {
    color: '#ffffff',
  },
};

const Question = ({ question, linkTo }) => (
  <div style={styles.container}>
    <a href={linkTo} style={styles.aText}>{question}</a>
  </div>
);

Question.propTypes = {
  question: PropTypes.string.isRequired,
  linkTo: PropTypes.string.isRequired,
};

export default Question;
