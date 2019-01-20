import React from 'react';
import PropTypes from 'prop-types';
import FlatButton from 'material-ui/FlatButton';
import { textDark, warmGreyBackgroundLight } from '../../assets/colors';
import ResponsesIcon from '../icons/ResponsesIcon';

const styles = {
  label: {
    paddingLeft: 0,
  },
  button: {
    minWidth: '60px',
    width: '60px',
  },
};

const CommentsButton = ({ total, href }) => (
  <FlatButton
    href={href}
    label={total}
    labelColor={textDark}
    labelPosition="before"
    hoverColor={warmGreyBackgroundLight}
    labelStyle={styles.label}
    style={styles.button}
    icon={<ResponsesIcon color={textDark} />}
  />
);

CommentsButton.propTypes = {
  total: PropTypes.number.isRequired,
  href: PropTypes.string.isRequired,
};

CommentsButton.defaultProps = {};

export default CommentsButton;
