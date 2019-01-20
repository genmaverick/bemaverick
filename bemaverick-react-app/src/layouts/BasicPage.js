import React from 'react';
import PropTypes from 'prop-types';
import { Grid, Row, Col } from 'react-flexbox-grid';
import App from '../containers/App';
import Meta from '../components/Meta';
import basicPageCss from '../assets/styles/basic-page.css';
import Header from '../components/header/Header';
import BannerTop from '../components/BannerTop';
import H1 from '../components/common/H1/BasicPage';
import Footer from '../components/footer/Footer';

const styles = {
  pageStyle: {
    display: 'flex',
    flexDirection: 'column',
    maxWidth: '100vw',
    minHeight: '100vh',
    overflowX: 'hidden',
  },
  contentWrapper: {
    flex: '1 0 auto',
    width: '90%',
    maxWidth: 750,
    margin: '0 auto',
    padding: '40px 5vw 40px 5vw',
  },
  grid: {},
};

const BasicPage = ({
  title, children, showBannerTop, pageStyle,
}) => (
  <App>
    <div style={{ ...styles.pageStyle, ...pageStyle }}>
      <Meta title={title} css={basicPageCss} />
      <Header />
      {showBannerTop && <BannerTop />}
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
  showBannerTop: PropTypes.bool,
  pageStyle: PropTypes.object,
};

BasicPage.defaultProps = {
  showBannerTop: true,
  pageStyle: {},
};

export default BasicPage;
