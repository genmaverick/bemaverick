/**
 * https://www.npmjs.com/package/react-loading
 * https://codesandbox.io/s/mqx0ql55qp
 */
import React from 'react';
import PropTypes from 'prop-types';
import ReactLoading from 'react-loading';
import { teal } from '../../assets/colors';

const Loading = ({
  type, color, width, height,
}) => (
  <ReactLoading type={type} color={color} width={width} height={height} />
);

Loading.propTypes = {
  type: PropTypes.string,
  color: PropTypes.string,
  width: PropTypes.oneOfType([PropTypes.string, PropTypes.number]),
  height: PropTypes.oneOfType([PropTypes.string, PropTypes.number]),
};

Loading.defaultProps = {
  type: 'bubbles',
  color: teal,
  width: 50,
  height: 20,
};

export default Loading;
