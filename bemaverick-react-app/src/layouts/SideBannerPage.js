import React from 'react';
import PropTypes from 'prop-types';
import { Grid, Row, Col } from 'react-flexbox-grid';
import App from '../containers/App';
import Meta from '../components/Meta';
import Header from '../components/header/Header';
import logoImgUrl from '../assets/images/logo-brandmark-2.svg';
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
    display: 'flex',
    flex: '1 0 auto',
    position: 'relative',
  },
  grid: {
    display: 'flex',
    width: '100%',
    padding: 0,
  },
  row: {
    width: '100%',
    margin: 0,
  },
  sideBanner: {
    display: 'flex',
    justifyContent: 'center',
    position: 'relative',
    padding: 0,
    backgroundColor: '#098c87',
    background: 'linear-gradient(45deg, #2d4670 0%,#1e6f8e 16%,#00a8b0 46%)',
  },
  maverickLogoCont: {
    display: 'flex',
    justifyContent: 'center',
    alignItems: 'center',
    position: 'absolute',
    width: '100%',
    height: '100%',
  },
  maverickLogo: {
    width: '40%',
    maxHeight: '80%',
    opacity: '0.2',
  },
  rightColumn: {
    padding: '40px 50px 30px 50px',
  },
};

const BasicPage = ({ title, children }) => (
  <App>
    <div style={styles.appStyle}>
      <Meta title={title} />
      <Header />
      <div style={styles.contentWrapper}>
        <Grid style={styles.grid} fluid>
          <Row style={styles.row}>
            <Col xs={12} md={4} style={styles.sideBanner}>
              <div style={styles.maverickLogoCont}>
                <img src={logoImgUrl} alt="maverick-logo" style={styles.maverickLogo} />
              </div>
              {children[0]}
            </Col>
            <Col xs={12} md={8} style={styles.rightColumn}>
              <H1>{title}</H1>
              {children[1]}
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
