import React from 'react';
import PropTypes from 'prop-types';
import H2 from '../common/H2';
import Question from './Question';

const styles = {
  questionContainer: {
    backgroundColor: '#000000',
    padding: '30px 40px 30px 40px',
    marginBottom: '50px',
  },
  div: {
    marginBottom: '50px',
  },
};

const createMarkup = html => ({ __html: html });

const FaqMavericks = ({ contentFamilies }) => {
  const questions = JSON.parse(contentFamilies);
  const titleArr = [];
  const answerArr = [];

  for (let x = 0; x < questions.length; x += 1) {
    const linkString = `#${(x + 50).toString()}`;
    titleArr.push((
      <div key={x}>
        <Question question={questions[x].title.rendered} linkTo={linkString} />
      </div>
    ));
    const answerTitle = <a name={(x + 50).toString()}><H2>{questions[x].title.rendered}</H2></a>;
    const answerContent = (
      <div
        dangerouslySetInnerHTML={createMarkup(questions[x].content.rendered)}
        style={styles.div}
      />
    );
    answerArr.push(<div key={x}>{answerTitle}{answerContent}</div>);
  }

  return (
    <div>
      <div style={styles.questionContainer}>
        { titleArr}
      </div>
      {answerArr}
    </div>
  );
};

FaqMavericks.propTypes = {
  contentFamilies: PropTypes.string.isRequired,
};

export default FaqMavericks;
