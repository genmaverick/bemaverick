import React from 'react';
import PropTypes from 'prop-types';
import { Grid, Row, Col } from 'react-flexbox-grid';
import App from '../containers/App';
import Meta from '../components/Meta';
import basicPageCss from '../assets/styles/basic-page.css';
import aboutPageCss from '../assets/styles/about-page.css';
import Header from '../components/header/Header';
import BannerTop from '../components/BannerTop';
import H1 from '../components/common/H1/BasicPage';
import Footer from '../components/footer/Footer';

const styles = {
  appStyle: {
    display: 'flex',
    flexDirection: 'column',
    maxWidth: '100vw',
    minHeight: '100vh',
    overflowX: 'hidden',
  },
  contentWrapper: {
    flex: '1 0 auto',
    width: '90%',
    maxWidth: 900,
    margin: '0 auto',
    padding: '40px 5vw 40px 5vw',
  },
  grid: {
  },
};

const BasicPage = ({ title, children }) => (
  <App>
    <div style={styles.appStyle}>
      <Meta title={title} css={aboutPageCss + basicPageCss} />
      <Header />
      <BannerTop url="https://s3.amazonaws.com/bemaverick-website-images/team-photo.png" />
      <div style={styles.contentWrapper}>
        <Grid style={styles.grid} fluid>
          <Row>
            <Col xs={12}>
              <H1>{title}</H1>
            </Col>
          </Row>
          <Row>
            <Col xs={12}>
              <section>{children} </section>
            </Col>
          </Row>
        </Grid>
      </div>
      <Footer />
    </div>
  </App>
);

BasicPage.propTypes = {
  title: PropTypes.string.isRequired,
  children: PropTypes.oneOfType([PropTypes.node, PropTypes.arrayOf(PropTypes.node)]).isRequired,
};

export default BasicPage;
