import React from "react";
import PropTypes from "prop-types";
import App from "../containers/App";
import BannerTop from "../components/BannerTop";
import Footer from "../components/footer/Footer";
import Header from "../components/header/Header";
import Meta from "../components/Meta";

const styles = {
  pageStyle: {
    display: "flex",
    flexDirection: "column",
    minHeight: '100vh',
  }
};

const SharePage = ({
  title,
  children,
  showBannerTop,
  pageStyle,
  metaProps
}) => (
  <App>
    <div style={{ ...styles.pageStyle, ...pageStyle }}>
      <Meta
        title={title}
        metaProps={metaProps}
        // css={basicPageCss}
      />
      <Header />
      {showBannerTop && <BannerTop />}
      {children}
      <Footer />
    </div>
  </App>
);

SharePage.propTypes = {
  title: PropTypes.string.isRequired,
  children: PropTypes.oneOfType([
    PropTypes.node,
    PropTypes.arrayOf(PropTypes.node)
  ]).isRequired,
  showBannerTop: PropTypes.bool,
  pageStyle: PropTypes.object,
  metaProps: PropTypes.object
};

SharePage.defaultProps = {
  showBannerTop: false,
  pageStyle: {},
  metaProps: {}
};

export default SharePage;
