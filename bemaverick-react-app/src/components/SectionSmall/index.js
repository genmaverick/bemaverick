import React from 'react';
import PropTypes from 'prop-types';
import Radium from 'radium';

const styles = {
  contentWrapperOuter: {},
  contentWrapperInner: {
    flex: '1 0 auto',
    width: 'auto',
    maxWidth: 320,
    margin: '0 auto',
    padding: '20px 5vw 20px 5vw',
  },
};

const SectionSmall = ({
  children, background, maxWidth, textAlign, fontStyle,
}) => {
  const outerStyle = { ...styles.contentWrapperOuter };
  const innerStyle = { ...styles.contentWrapperInner, ...fontStyle };
  
  // Custom styles
  outerStyle.background = background || 'transparent';
  innerStyle.maxWidth = maxWidth;
  innerStyle.textAlign = textAlign;

  return (
    <div style={outerStyle}>
      <div style={innerStyle}>{children}</div>
    </div>
  );
};

SectionSmall.propTypes = {
  children: PropTypes.oneOfType([PropTypes.node, PropTypes.arrayOf(PropTypes.node)]).isRequired,
  background: PropTypes.oneOfType([PropTypes.string, PropTypes.bool]),
  maxWidth: PropTypes.number,
  textAlign: PropTypes.string,
  fontStyle: PropTypes.object,
};

SectionSmall.defaultProps = {
  background: false,
  maxWidth: 320,
  textAlign: 'left',
  fontStyle: {},
};

export default Radium(SectionSmall);
