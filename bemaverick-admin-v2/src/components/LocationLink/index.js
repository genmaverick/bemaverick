import React from "react";
import PropTypes from "prop-types";
import pure from "recompose/pure";
import DesktopIcon from "@material-ui/icons/OpenInNew";
import config from "config";
const { webAppUrl } = config;

const styles = {
  link: {
    color: '#00a8b0',
    weight: 'bold',
    textDecoration: 'none',
    fontFamily: 'Arial, Helvetica, sans-serif',
  },
  container: {
    display: 'flex',
    alignItems: 'center',
  }
};

export const PremiumField = ({
  contentType,
  source,
  basePath,
  record = {},
  ...rest
}) => {
  let url;

  if(contentType == 'content') {
    url = `${webAppUrl}/${record.parentType}s/${record.parentId}`;
  } else if (contentType == 'user') {
    url = `${webAppUrl}/users/${record.userId}`;
  }

    return (
      <a href={url} target="_blank" style={styles.link}>
        <div style={styles.container}>
          <DesktopIcon color="primary" />
          {url}
        </div>
      </a>
    );
};

PremiumField.propTypes = {
  contentType: PropTypes.string,
  basePath: PropTypes.string,
  cellClassName: PropTypes.string,
  headerClassName: PropTypes.string,
  label: PropTypes.string,
  record: PropTypes.object,
};

const PurePremiumField = pure(PremiumField);

PurePremiumField.defaultProps = {};

export default PurePremiumField;
