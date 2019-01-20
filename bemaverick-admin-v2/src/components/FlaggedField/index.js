import React from "react";
import PropTypes from "prop-types";
import get from "lodash/get";
import pure from "recompose/pure";
import FlagIcon from "@material-ui/icons/Flag";

export const FlaggedField = ({
  className,
  source,
  basePath,
  record = {},
  ...rest
}) => {
  if (get(record, source) === true) {
    return (
      <FlagIcon color="secondary" />
    );
  }
  return (
    <FlagIcon color="disabled" />
  );
};

FlaggedField.propTypes = {
  basePath: PropTypes.string,
  className: PropTypes.string,
  cellClassName: PropTypes.string,
  headerClassName: PropTypes.string,
  label: PropTypes.string,
  record: PropTypes.object,
  source: PropTypes.string.isRequired
};

const PureFlaggedField = pure(FlaggedField);

PureFlaggedField.defaultProps = {};

export default PureFlaggedField;
