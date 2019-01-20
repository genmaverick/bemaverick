import React from 'react';
import PropTypes from 'prop-types';
import MaterialUICheckbox from 'material-ui/Checkbox';
import { borderLight, textDark } from '../../assets/colors';

const styles = {
  checkbox: {
    textAlign: 'left',
  },
  label: {
    fontSize: '12pt',
    fontWeight: '200',
    textAlign: 'left',
    color: textDark,
    marginTop: '-5px',
  },
  icon: { fill: borderLight, width: 24, marginRight: 16 },
  error: {
    position: 'relative',
    bottom: 2,
    fontSize: 12,
    lineHeight: '12px',
    color: 'rgb(244, 67, 54)',
    marginTop: 10,
    // transition: transitions.easeOut(),
  },
};

const Checkbox = ({
  input, label, color, margin, lineHeight, meta: { touched, error },
}) => (
  <section>
    <MaterialUICheckbox
      label={label}
      checked={!!input.value}
      onCheck={input.onChange}
      iconStyle={styles.icon}
      labelStyle={{ ...styles.label, color, lineHeight }}
      style={{ ...styles.checkbox, margin }}
    />
    {error && touched && <div style={styles.error}>{error}</div>}
  </section>
);

Checkbox.propTypes = {
  input: PropTypes.object,
  label: PropTypes.string,
  color: PropTypes.string,
  margin: PropTypes.string,
  lineHeight: PropTypes.string,
  meta: PropTypes.shape({
    touched: PropTypes.bool,
    error: PropTypes.oneOfType([PropTypes.string, PropTypes.object]),
  }),
};

Checkbox.defaultProps = {
  input: {},
  label: '',
  color: '#000000',
  margin: '0',
  lineHeight: '1.4',
  meta: { touched: false, error: '' },
};

export default Checkbox;
