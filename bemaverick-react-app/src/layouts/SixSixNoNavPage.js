import React from "react";
import PropTypes from "prop-types";
import MediaQuery from "react-responsive";
import { Grid, Row, Col } from "react-flexbox-grid";
import App from "../containers/App";
import Meta from "../components/Meta";
import Header from "../components/header/NavBar";
// import Footer from '../components/footer/Footer';
import BannerDownloadApp from "../components/BannerDownloadApp";

const styles = {
  appStyle: {
    display: "flex",
    flexDirection: "column",
    maxWidth: "100vw",
    minHeight: "100vh",
    overflowX: "hidden"
  },
  contentWrapper: {
    display: "flex",
    flex: "1 0 auto",
    position: "relative"
  },
  grid: {
    display: "flex",
    width: "100%",
    padding: 0
  },
  row: {
    width: "100%",
    margin: 0
  },
  columnLeft: {
    display: "flex",
    justifyContent: "center",
    position: "relative",
    padding: 0,
    backgroundColor: "#098c87",
    background: "linear-gradient(45deg, #2d4670 0%,#1e6f8e 16%,#00a8b0 46%)"
  },
  columnLeftMobile: {
    display: "flex",
    minHeight: "calc(100vh - 430px)",
    justifyContent: "center",
    position: "relative",
    padding: 0,
    backgroundColor: "#098c87",
    background: "linear-gradient(45deg, #2d4670 0%,#1e6f8e 16%,#00a8b0 46%)"
  },
  columnRight: {
    display: "flex",
    justifyContent: "center",
    padding: "50px 0 50px 0"
  }
};

const HomePage = ({ children }) => (
  <App>
    <div style={styles.appStyle}>
      <Meta />
      <Header />
      <div style={styles.contentWrapper}>
        <Grid fluid style={styles.grid}>
          <Row style={styles.row}>
            <MediaQuery query="(max-width: 575px)">
              <Col xs={12} md={6} style={styles.columnLeftMobile}>
                {children[0]}
              </Col>
              <Col xs={12} md={6}>
                {children[1]}
              </Col>
            </MediaQuery>
            <MediaQuery query="(min-width: 576px)">
              <Col xs={12} md={6} style={styles.columnLeft}>
                {children[0]}
              </Col>
              <Col xs={12} md={6} style={styles.columnRight}>
                {children[1]}
              </Col>
            </MediaQuery>
          </Row>
        </Grid>
      </div>
      <BannerDownloadApp />
    </div>
  </App>
);

HomePage.propTypes = {
  children: PropTypes.oneOfType([
    PropTypes.node,
    PropTypes.arrayOf(PropTypes.node)
  ]).isRequired
};

export default HomePage;
