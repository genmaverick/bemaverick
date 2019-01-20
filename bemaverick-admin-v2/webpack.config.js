const path = require("path");
const webpack = require("webpack");
const HtmlWebpackPlugin = require("html-webpack-plugin");
const HardSourceWebpackPlugin = require("hard-source-webpack-plugin");
const dotenv = require("dotenv");

module.exports = env => {
  // Load .env Variables
  const nodeEnv = env.NODE_ENV || "development";
  const environmentFile = `./.env/.${nodeEnv}.env`;
  dotenv.load({ path: environmentFile });
  const envDefinitions = {};
  for (let [key, value] of Object.entries(process.env)) {
    envDefinitions[`process.env.${key}`] = JSON.stringify(value);
  }
  envDefinitions["process.env.NODE_ENV"] = JSON.stringify(
    env.NODE_ENV || "unknown"
  );
  console.log(`Loading "${env.NODE_ENV}" environment variables`);
  console.log('ENV', process.env);

  return {
    devtool: "cheap-module-source-map",
    output: {
      filename: "[name].[hash].js"
    },
    module: {
      rules: [
        {
          test: /\.js$/,
          exclude: /node_modules/,
          use: { loader: "babel-loader" }
        },
        {
          test: /\.css$/,
          // exclude: /node_modules/,
          include: [
            path.resolve(__dirname, "src"),
            path.resolve(__dirname, "node_modules/react-admin-color-input"),
            path.resolve(__dirname, "node_modules/ra-input-rich-text")
          ],
          use: [{ loader: "style-loader" }, { loader: "css-loader" }]
        },
        {
          test: /\.html$/,
          exclude: /node_modules/,
          use: { loader: "html-loader" }
        }
      ]
    },
    plugins: [
      new HtmlWebpackPlugin({
        template: "./src/index.html"
      }),
      new HardSourceWebpackPlugin(),
      new webpack.DefinePlugin(envDefinitions)
    ],
    resolve: {
      alias: {
        components: path.join(__dirname, "src", "components"),
        config: path.join(__dirname, "src", "config"),
        i18n: path.join(__dirname, "src", "i18n"),
        lib: path.join(__dirname, "src", "lib"),
        resources: path.join(__dirname, "src", "resources")
      }
    },
    devServer: {
      stats: {
        children: false,
        chunks: false,
        modules: false
      },
      port: 8080
    },
    output: {
      filename: "[name].[hash].js"
    },
  };
};
