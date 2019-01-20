import React from 'react';
import PropTypes from 'prop-types';

const styles = {
  buttonContainer: {
    display: 'flex',
    justifyContent: 'center',
    alignItems: 'center',
    height: '40px',
    backgroundColor: '#00B0AC',
    borderRadius: '20px',
  },
  linkText: {
    fontSize: 18,
    fontWeight: 500,
    textTransform: 'uppercase',
    textDecoration: 'none',
    color: '#ffffff',
  },
};

const FormButton = ({ buttonName, buttonUrl, widthObj }) => (
  <a style={styles.linkText} href={buttonUrl}>
    <div style={{ ...widthObj, ...styles.buttonContainer }}>
      {buttonName}
    </div>
  </a>
);

const styleShape = {
  width: PropTypes.string.isRequired,
  margin: PropTypes.string.isRequired,
};

FormButton.propTypes = {
  buttonName: PropTypes.string.isRequired,
  buttonUrl: PropTypes.string.isRequired,
  widthObj: PropTypes.shape(styleShape).isRequired,
};

export default FormButton;
