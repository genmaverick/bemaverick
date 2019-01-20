import React from "react";
import PropTypes from "prop-types";
import { Grid, Row, Col } from "react-flexbox-grid";
import App from "../containers/App";
import Meta from "../components/Meta";
import Header from "../components/header/Header";
import Footer from "../components/footer/Footer";

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
    position: "relative",
    backgroundColor: "#098c87",
    background: "linear-gradient(45deg, #2d4670 0%,#1e6f8e 16%,#00a8b0 46%)"
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
    padding: 0
  },
  columnRight: {
    display: "flex",
    justifyContent: "center",
    padding: "0"
  }
};

const HomePage = ({ children }) => (
  <App>
    <div style={styles.appStyle}>
      <Meta description="Maverick is a next-gen social network where you can flex your creative muscles and connect with new friends. Browse videos from inspiring creators and amazing role models, respond to challenges that push you to exercise and to share your creative skills, and connect and build community with fellow Mavericks." />
      <Header />
      <div style={styles.contentWrapper}>
        <Grid fluid style={styles.grid}>
          <Row style={styles.row}>
            <Col xs={12} lg={7} style={styles.columnLeft}>
              {children[0]}
            </Col>
            <Col xs={12} lg={5} style={styles.columnRight}>
              {children[1]}
            </Col>
          </Row>
        </Grid>
      </div>
      <Footer />
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
