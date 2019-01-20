/* eslint react/jsx-key: off */
import "babel-polyfill";
import React from "react";
import { Admin, Resource } from "react-admin"; // eslint-disable-line import/no-unresolved
import { render } from "react-dom";
import { Route } from "react-router";
import Menu from "components/Menu";
import authProvider from "./lib/authProvider";
// import CustomRouteLayout from "./_archive/customRouteLayout";
// import CustomRouteNoLayout from "./_archive/customRouteNoLayout";
import dataProvider from "./lib/dataProviders";
import i18nProvider from "./lib/i18nProvider";
import themes from "./resources/themes";
import comments from "./resources/comments";
import rewards from "./resources/rewards";
// import posts from "./resources/posts";
// import users from "./resources/users";
import config from "config";
import muiTheme from "config/theme";
import { version } from "../package.json";

if (config.nodeEnv !== "production" || true) {
  console.log(`-- ${config.nodeEnv} mode --`);
}

const [major, minor /*, patch */] = version.split(".");

render(
  <Admin
    theme={muiTheme}
    authProvider={authProvider}
    dataProvider={dataProvider}
    i18nProvider={i18nProvider}
    menu={Menu}
    title={`Maverick Admin Tools ${major}.${minor}`}
    locale="en"
    // customRoutes={[
    //   <Route exact path="/custom" component={CustomRouteNoLayout} noLayout />,
    //   <Route exact path="/custom2" component={CustomRouteLayout} />
    // ]}
  >
    {permissions => [
      <Resource name="themes" create={themes.CreateTheme} {...themes} />,
      <Resource name="comments" {...comments} />,
      <Resource name="rewards" {...rewards} />,
      // <Resource name="posts" {...posts} />,
      // permissions ? <Resource name="users" {...users} /> : null,
      <Resource name="tags" />
    ]}
  </Admin>,
  document.getElementById("root")
);
