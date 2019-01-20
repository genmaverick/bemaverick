import React, { Component } from 'react';
// import PropTypes from 'prop-types';
import { connect } from 'react-redux';
import Button from '@material-ui/core/Button';
import ThumbDown from '@material-ui/icons/ThumbDown';
import { translate } from 'react-admin';
import compose from 'recompose/compose';

import PropTypes from "prop-types";
import get from "lodash/get";
import pure from "recompose/pure";
import ActiveIcon from "@material-ui/icons/Done";
import InactiveIcon from "@material-ui/icons/Clear";
import { activeToFalse, activeToTrue } from './activeActions';

class AcceptButton extends Component {
  handleActivate = () => {
      const { activeToTrue, record } = this.props;
      activeToTrue(record._id, record);
  };

  handleDeactivate = () => {
    const { activeToFalse, record } = this.props;
    activeToFalse(record._id, record);
  };

  render() {
      const { record, translate } = this.props;
      return record && record.active === true ? (
        <Button size="small" onClick={this.handleDeactivate}>
            <ActiveIcon />
            {/* {translate('resources.reviews.action.reject')} */}
        </Button>
    ) : (
      <Button size="small" onClick={this.handleActivate}>
        <InactiveIcon 
          color="disabled"
        />
        {/* {translate('resources.reviews.action.reject')} */}
      </Button>
    );
  }
}

AcceptButton.propTypes = {
  record: PropTypes.object,
  activeToFalse: PropTypes.func,
  translate: PropTypes.func,
};

const enhance = compose(
  translate,
  connect(
      null,
      {
        activeToFalse,
        activeToTrue,
      }
  )
);

export default enhance(AcceptButton);
