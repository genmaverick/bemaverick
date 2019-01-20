import React from 'react';
import PropTypes from 'prop-types';
import SvgIcon from 'material-ui/SvgIcon';

const SkewedRectangle = ({ color, styleObj }) => (
  <div>
    <SvgIcon viewBox="0 0 60 55" color={color} style={styleObj}>
      <path d="M15,28.1l5.1-5.2L15,17.8V28.1z M31.3,13.2l-3.6,3.6v12.3l3.6,3.6V13.2z M10.4,32.7l3.6-3.6V16.8l-3.6-3.6V32.7 z M14,33.4v-2.9l-2.9,2.9H14z M26.7,17.8l-5.2,5.1l5.2,5.2V17.8z M27.7,30.5v2.9h2.9L27.7,30.5z M20.8,0L0,11.5v23L20.8,46 l20.8-11.5v-23L20.8,0z M32.3,34.4h-5.6v-4.9l-5.9-5.9L15,29.5v4.9H9.4V10.8l11.5,11.5l11.5-11.5v23.6H32.3z" />
    </SvgIcon>
  </div>
);

const styleShape = {
  margin: PropTypes.string.isRequired,
  height: PropTypes.string.isRequired,
  width: PropTypes.string.isRequired,
};

SkewedRectangle.propTypes = {
  color: PropTypes.string.isRequired,
  styleObj: PropTypes.shape(styleShape).isRequired,
};

export default SkewedRectangle;
