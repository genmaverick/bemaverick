import React from "react";
import PropTypes from "prop-types";
import get from "lodash/get";
import pure from "recompose/pure";
import PremiumIcon from "@material-ui/icons/Lock";

export const PremiumField = ({
  className,
  source,
  basePath,
  record = {},
  ...rest
}) => {
  if (get(record, source) === true) {
    return (
      <span
        style={{ display: "flex", flexDirection: "row", alignItems: "center" }}
      >
        <PremiumIcon className={className} {...rest} />
        {record.availability.minPosts} /
        {record.availability.minBadges}
      </span>
    );
  }

  return "";
};

PremiumField.propTypes = {
  basePath: PropTypes.string,
  className: PropTypes.string,
  cellClassName: PropTypes.string,
  headerClassName: PropTypes.string,
  label: PropTypes.string,
  record: PropTypes.object,
  source: PropTypes.string.isRequired
};

const PurePremiumField = pure(PremiumField);

PurePremiumField.defaultProps = {};

export default PurePremiumField;
