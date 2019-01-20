// server.js
const next = require("next");
const routes = require("./routes");
const nextConfig = require("./next.config");
const serverMetaFilter = require("./serverMetaFilter");

const app = next({
  dir: "./src",
  dev: process.env.NODE_ENV !== "production",
  conf: nextConfig
});
const handler = routes.getRequestHandler(app);

// vars
const port = process.env.PORT || 3000;

// With express
const express = require("express");

console.log("Starting server..."); // eslint-disable-line no-console
app.prepare().then(() => {
  express()
    .use(serverMetaFilter)
    .use(handler)
    .listen(port);

  console.log(`🍟  Server started on port ${port}`); // eslint-disable-line no-console
});
