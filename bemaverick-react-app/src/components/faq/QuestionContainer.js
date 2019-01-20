import React from 'react';
import PropTypes from 'prop-types';

import rectangleImg from '../../assets/images/skewed-rectangle-large.svg';

const styles = {
  wholeContainer: {
    display: 'flex',
    justifyContent: 'center',
    alignItems: 'center',
    position: 'relative',
  },
  rectangle: {
    width: '100%',
  },
  questionContainer: {
    position: 'absolute',
    width: '90%',
    height: '70%',
    overflowY: 'scroll',
  },
};

const QuestionContainer = ({ children }) => (
  <div style={styles.wholeContainer} >
    <img src={rectangleImg} style={styles.rectangle} alt="faq-container" />
    <div style={styles.questionContainer}>
      { children }
    </div>
  </div>
);

QuestionContainer.propTypes = {
  children: PropTypes.oneOfType([PropTypes.node, PropTypes.arrayOf(PropTypes.node)]).isRequired,
};

export default QuestionContainer;
