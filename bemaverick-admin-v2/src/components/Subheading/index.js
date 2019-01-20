import React from "react";
import PropTypes from "prop-types";
import Typography from "@material-ui/core/Typography";
import { withStyles } from "@material-ui/core/styles";

export default ({ children, basePath, ...props }) => {
  return (
    <Typography variant="subheading" {...props} styles={{ marginTop: 40 }}>
      {children}
    </Typography>
  );
};
