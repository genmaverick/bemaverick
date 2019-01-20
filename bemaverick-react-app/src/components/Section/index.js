import React from 'react';
import PropTypes from 'prop-types';
import Radium from 'radium';
import { mediumBreakpoint } from '../../assets/breakpoints';

const styles = {
  contentWrapperOuter: {
    // flex: 1,
  },
  contentWrapperInner: {
    flex: '1 0 auto',
    width: 'auto',
    margin: '0 auto',
    [mediumBreakpoint]: {
      padding: '40px 5vw 40px 5vw',
    },
  },
};

const Section = ({
  children, background, maxWidth, textAlign, flexGrow,
}) => {
  const contentWrapperOuterStyle = { ...styles.contentWrapperOuter };
  const contentWrapperInnerStyle = { ...styles.contentWrapperInner };

  contentWrapperInnerStyle.maxWidth = maxWidth;
  contentWrapperInnerStyle.textAlign = textAlign;
  contentWrapperOuterStyle.background = background || 'transparent';

  return (
    <div style={{...contentWrapperOuterStyle, flexGrow }}>
      <div style={contentWrapperInnerStyle}>{children}</div>
    </div>
  );
};

Section.propTypes = {
  children: PropTypes.oneOfType([PropTypes.node, PropTypes.arrayOf(PropTypes.node)]).isRequired,
  background: PropTypes.oneOfType([PropTypes.string, PropTypes.bool]),
  maxWidth: PropTypes.number,
  textAlign: PropTypes.string,
  flexGrow: PropTypes.string,
};

Section.defaultProps = {
  background: false,
  maxWidth: 960,
  textAlign: 'left',
  flexGrow: '0',
};

export default Radium(Section);
