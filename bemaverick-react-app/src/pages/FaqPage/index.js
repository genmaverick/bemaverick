/* eslint import/first: 0 */
import React from 'react';
import PropTypes from 'prop-types';
import config from '../../utils/config';
import axios from 'axios';
import { Tabs, Tab } from 'material-ui/Tabs';
import BasicPage from '../../layouts/BasicPage';
import FaqMavericks from '../../components/faq/FaqMavericks';
import FaqFamilies from '../../components/faq/FaqFamilies';

const styles = {
  pageContent: {
    marginTop: '25px',
  },
  tabs: {
    width: '240px',
    fontFamily: 'Barlow, sans-serif',
  },
  inkBar: {
    width: '120px',
    height: '3px',
    backgroundColor: '#00B0AC',
    marginTop: '-10px',
  },
  materialContent: {
    width: '80vw',
    maxWidth: '750px',
  },
  faqContent: {
    marginTop: '25px',
  },
};

const FAQ = ({ contentMavericks, contentFamilies }) => (
  <BasicPage title="FAQ">
    <div style={styles.pageContent}>
      <Tabs
        style={styles.tabs}
        inkBarStyle={styles.inkBar}
        contentContainerStyle={styles.materialContent}
      >
        <Tab label="Mavericks" className="material-tab" >
          <div style={styles.faqContent}>
            <FaqMavericks contentMavericks={contentMavericks} />
          </div>
        </Tab>
        <Tab label="Families" className="material-tab">
          <div style={styles.faqContent}>
            <FaqFamilies contentFamilies={contentFamilies} />
          </div>
        </Tab>
      </Tabs>
    </div>
  </BasicPage>
);
FAQ.getInitialProps = async () => {
  try {
    const contentMavericks = await axios(`${config.maverickCms.url}/posts?page=1&per_page=30&categories=4&order=asc`);
    const contentFamilies = await axios(`${config.maverickCms.url}/posts?page=1&per_page=30&categories=7&order=asc`);
    return {
      contentMavericks: JSON.stringify(contentMavericks.data),
      contentFamilies: JSON.stringify(contentFamilies.data),
    };
  } catch (error) {
    return { content: '', loading: false, error: error.toString() };
  }
};

FAQ.propTypes = {
  contentMavericks: PropTypes.string,
  contentFamilies: PropTypes.string,
};

FAQ.defaultProps = {
  contentMavericks: '...',
  contentFamilies: '...',
};

export default FAQ;
