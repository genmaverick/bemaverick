import React from "react";
import { connect } from "react-redux";
import compose from "recompose/compose";
import SettingsIcon from "@material-ui/icons/Settings";
import MenuItem from "@material-ui/core/MenuItem";
import ListIcon from "@material-ui/icons/List";
import {
  translate,
  DashboardMenuItem,
  MenuItemLink,
  Responsive
} from "react-admin";
import { withRouter } from "react-router-dom";

import Themes from "resources/themes";
import Comments from "resources/comments";
import Rewards from "resources/rewards";
import { titleCase } from "lib/utils";
import config from "config";
import MenuItemLinkAnchor from "components/MenuItemLinkAnchor";

const { v1AdminBaseUrl } = config;

const items = [
  { name: "challenges", href: `${v1AdminBaseUrl}/challenges` },
  { name: "responses", href: `${v1AdminBaseUrl}/responses` },
  { name: "catalysts", href: `${v1AdminBaseUrl}/mentors` },
  { name: "mavericks", href: `${v1AdminBaseUrl}/kids` },
  { name: "parents", href: `${v1AdminBaseUrl}/parents` },
  { name: "tools", href: `${v1AdminBaseUrl}/tools` },
  { name: "streams", href: `${v1AdminBaseUrl}/streams` },
  { name: "badges", href: `${v1AdminBaseUrl}/badges` },
  { name: "themes", icon: <Themes.icon /> },
  { name: "comments", icon: <Comments.icon /> },
  { name: "rewards", icon: <Rewards.icon /> }
];

const styles = {
  main: {
    display: "flex",
    flexDirection: "column",
    justifyContent: "flex-start",
    height: "100%"
  }
};

const Menu = ({ onMenuClick, translate, logout }) => (
  <div style={styles.main}>
    {/* <DashboardMenuItem onClick={onMenuClick} /> */}
    {items.map(item => {
      if (item.href) {
        // standard HTML anchor link
        return (
          <MenuItemLinkAnchor
            key={item.name}
            primaryText={translate(`resources.${item.name}.name`, {
              smart_count: 2,
              _: titleCase(item.name)
            })}
            component="a"
            href={item.href}
            leftIcon={item.icon || <ListIcon />}
            onClick={onMenuClick}
          />
        );
      } else {
        // react-admin (react-router) link
        return (
          <MenuItemLink
            key={item.name}
            to={item.to || `/${item.name}`}
            primaryText={translate(`resources.${item.name}.name`, {
              smart_count: 2
            })}
            leftIcon={item.icon || <ListIcon />}
            onClick={onMenuClick}
          />
        );
      }
    })}

    <Responsive xsmall={logout} medium={null} />
  </div>
);

const enhance = compose(
  withRouter,
  connect(
    state => ({
      theme: state.theme,
      locale: state.i18n.locale
    }),
    {}
  ),
  translate
);

export default enhance(Menu);
