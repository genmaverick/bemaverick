/* eslint import/first: 0 */
import React from 'react';
import axios from 'axios';
import PropTypes from 'prop-types';
import config from '../../utils/config';
import AboutPage from '../../layouts/AboutPage';
import H1 from '../../components/common/H1/BasicPage';
import TeamHexgrid from '../../components/TeamHexgrid';

const styles = {
  aboutText: {
    margin: '-5px 0 50px 0',
  },
  hexGrid: {
    margin: '40px 0 60px 0',
  },
  center: {
    display: 'flex',
    justifyContent: 'center',
  },
};

const createMarkup = html => ({ __html: html });

const About = ({ content }) => (
  <AboutPage title="About Maverick">
    <div dangerouslySetInnerHTML={createMarkup(content)} style={styles.aboutText} />
    <H1>The Team</H1>
    <div style={styles.hexGrid}>
      <TeamHexgrid />
    </div>
    <div style={styles.center}>
      <p>
        INTERESTED IN JOINING TEAM MAVERICK? DO YOUR THING AT{' '}
        <a href="mailto:careers@bemaverick.com">CAREERS@BEMAVERICK.COM</a>
      </p>
    </div>
  </AboutPage>
);

About.getInitialProps = async () => {
  try {
    const res = await axios(`${config.maverickCms.url}/pages/167`);
    return { content: res.data.content.rendered, loading: false, error: false };
  } catch (error) {
    return { content: '', loading: false, error: error.toString() };
  }
};

About.propTypes = {
  content: PropTypes.string,
};

About.defaultProps = {
  content: '',
};

export default About;
