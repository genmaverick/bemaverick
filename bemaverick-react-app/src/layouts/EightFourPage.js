import React from 'react';
import PropTypes from 'prop-types';
import { Grid, Row, Col } from 'react-flexbox-grid';
import App from '../containers/App';
import Meta from '../components/Meta';
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
    maxWidth: 960,
    margin: '50px 10vw 50px 10vw',
  },
};

const BasicPage = ({ title, children }) => (
  <App>
    <div style={styles.appStyle}>
      <Meta title={title} />
      <Header />
      <BannerTop />
      <div style={styles.contentWrapper}>
        <Grid style={styles.grid} fluid>
          <Row>
            <Col xs={12} md={12}>
              <H1>{title}</H1>
            </Col>
          </Row>
          <Row>
            <Col xs={12} md={8}>
              <section>{children[0]}</section>
            </Col>
            <Col xs={12} md={1} />
            <Col xs={12} md={3}>
              <section>{children[1]}</section>
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
