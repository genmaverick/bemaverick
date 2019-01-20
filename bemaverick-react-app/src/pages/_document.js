import React from "react";
import htmlescape from "htmlescape";
import Document, { Head, Main, NextScript } from "next/document";
import { textDark } from "../assets/colors";

// _document is only rendered on the server side and not on the client side
// Event handlers like onClick can't be added to this file

// ./pages/_document.js
import npprogressCss from "../assets/styles/npprogress.css";
import SegmentScript from "../components/scripts/SegmentScript";
import BranchScript from "../components/scripts/BranchScript";
import LeanplumScript from "../components/scripts/LeanplumScript";

// Map server env variables to window.__ENV__
require("dotenv").config();

const {
  MAVERICK_API_URL,
  MAVERICK_API_CLIENT_ID,
  MAVERICK_API_CLIENT_SECRET,
  MAVERICK_API_APP_KEY,
  MAVERICK_AWS_IMAGES_URL,
  MAVERICK_BRANCH_KEY,
  MAVERICK_CMS_URL,
  MAVERICK_LEANPLUM_APP_ID,
  MAVERICK_LEANPLUM_CLIENT_KEY,
  MAVERICK_SEGMENT_KEY,
  MAVERICK_BASE_URL
} = process.env;
const env = {
  MAVERICK_API_URL,
  MAVERICK_API_CLIENT_ID,
  MAVERICK_API_CLIENT_SECRET,
  MAVERICK_API_APP_KEY,
  MAVERICK_AWS_IMAGES_URL,
  MAVERICK_BRANCH_KEY,
  MAVERICK_CMS_URL,
  MAVERICK_LEANPLUM_APP_ID,
  MAVERICK_LEANPLUM_CLIENT_KEY,
  MAVERICK_SEGMENT_KEY,
  MAVERICK_BASE_URL
};

export default class MyDocument extends Document {
  static async getInitialProps(ctx) {
    const initialProps = await Document.getInitialProps(ctx);
    return { ...initialProps };
  }

  render() {
    return (
      <html lang="en-US">
        <Head>
          <link
            href="https://fonts.googleapis.com/css?family=Barlow:200,400,400i,500,600,600i,700,900"
            rel="stylesheet"
          />
          <style>
            {`html { font-family: Barlow, sans-serif; font-weight: 400; color: ${textDark} } \
              body { margin: 0; } \
              button:hover { cursor: pointer; } \
              /* custom! */`}
            {npprogressCss}
          </style>

          <script
            dangerouslySetInnerHTML={{ __html: `__ENV__ = ${htmlescape(env)}` }}
          />
          <BranchScript />
          <LeanplumScript />
        </Head>
        <body>
          <Main />
          <NextScript />
          <SegmentScript />
        </body>
      </html>
    );
  }
}
