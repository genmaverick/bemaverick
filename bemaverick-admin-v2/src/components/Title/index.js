import React from "react";
import PropTypes from "prop-types";
import Typography from "@material-ui/core/Typography";
import { withStyles } from "@material-ui/core/styles";

export default ({ children, basePath, ...props }) => (
  <Typography variant="title" style={{ marginTop: 60 }} {...props}>
    {children}
  </Typography>
);
