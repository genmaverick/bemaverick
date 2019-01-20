import React from 'react';
import PropTypes from 'prop-types';
import loadingImg from '../../assets/images/loading-spin.svg';

const Loading = ({ margin, width }) => {
  const style = {
    margin,
    width,
  };

  return <img src={loadingImg} style={style} alt="apple-store" />;
};

Loading.propTypes = {
  margin: PropTypes.string,
  width: PropTypes.oneOfType([PropTypes.string, PropTypes.number]),
};

Loading.defaultProps = {
  margin: '0',
  width: '100px',
};

export default Loading;
