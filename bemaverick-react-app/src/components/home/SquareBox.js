import React from 'react';
import PropTypes from 'prop-types';
import MediaQuery from 'react-responsive';
// import rectangleImg from '../../assets/images/skewed-rectangle-square.svg';
import rectangleImg from './skewed-rectangle-square.png';

const styles = {
  boxContMobile: {
    display: 'flex',
    justifyContent: 'center',
    alignItems: 'center',
    position: 'relative',
    width: '100vw',
    // minHeight: '300px',
    color: 'white',
  },
  boxContTablet: {
    display: 'flex',
    justifyContent: 'center',
    alignItems: 'center',
    position: 'relative',
    width: '100%',
    minWidth: '400px',
    maxWidth: '450px',
    minHeight: 400,
  },
  boxImg: {
    width: '100%',
  },
  signinMobile: {
    backgroundColor: '#000000',
    position: 'relative',
    width: '100%',
    padding: '20px 20px',
    margin: '0 0 0 0',
  },
  signinTablet: {
    // position: 'absolute',
    // width: '80%',
    // height: '88%',
    padding: '20px 40px',
    width: 400,

    background: `url(${rectangleImg})`,
    backgroundRepeat: 'no-repeat',
    backgroundPosition: '0 0',
    backgroundSize: '100% 100%',
  },
};

const SquareBox = ({ children }) => (
  <div>
    <MediaQuery query="(max-width: 575px)">
      <div style={styles.boxContMobile}>
        <div style={styles.signinMobile}>{children}</div>
      </div>
    </MediaQuery>
    <MediaQuery query="(min-width: 576px)">
      <div style={styles.boxContTablet}>
        {/* <img src={rectangleImg} style={styles.boxImg} alt="signin-box" /> */}
        <div style={styles.signinTablet}>{children}</div>
      </div>
    </MediaQuery>
  </div>
);

SquareBox.propTypes = {
  children: PropTypes.oneOfType([PropTypes.node, PropTypes.arrayOf(PropTypes.node)]).isRequired,
};

export default SquareBox;
