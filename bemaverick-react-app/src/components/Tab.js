import React from 'react';
import PropTypes from 'prop-types';

const styles = {
  tabActive: {
    display: 'inline-block',
    margin: '0 10px 0 10px',
    paddingBottom: '3px',
    borderBottom: ' 3px solid #00B0AC',
    fontSize: '18px',
    textTransform: 'uppercase',
    cursor: 'pointer',
  },
  tabInactive: {
    display: 'inline-block',
    margin: '0 10px 0 10px',
    paddingBottom: '6px',
    fontSize: '18px',
    textTransform: 'uppercase',
    color: '#9B9B9B',
    cursor: 'pointer',
  },
};

const Tab = ({ title, textColor, active }) => {
  if (active) {
    const color = { color: textColor };
    return (
      <div style={{ ...styles.tabActive, ...color }}>
        {title}
      </div>
    );
  }
  return (
    <div style={styles.tabInactive}>
      {title}
    </div>
  );
};

Tab.propTypes = {
  title: PropTypes.string.isRequired,
  textColor: PropTypes.string.isRequired,
  active: PropTypes.bool.isRequired,
};

export default Tab;
