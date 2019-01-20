import React from "react";
import PropTypes from "prop-types";
import Head from "next/head";

const logoTeal = "https://cdn.genmaverick.com/logo/logo-teal.png";
const googleSiteVerification = process.env.GOOGLE_SITE_VERIFICATION || null;

const Meta = ({ title, css, description, image, metaProps }) => {
  const defaultTitle = "Watch on Maverick | A Positive Community";
  const customTitle = title ? `${title} | Maverick` : defaultTitle;
  const og_image = metaProps["og:image"] || image;
  const og_image_width = metaProps["og:image:width"] || 579;
  const og_image_height = metaProps["og:image:height"] || 400;
  const og_title = metaProps["og:title"] || customTitle;
  const og_description = metaProps["og:description"] || description;
  const fb_app_id = metaProps["fb:app_id"] || "2098769993734812";
  const og_type = metaProps["og:type"] || "website";
  return (
    <div>
      <Head>
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <meta charSet="utf-8" />
        <title>{og_title}</title>
        <meta name="description" content={og_description} />
        {/* sharing metadata */}
        {og_image && <meta property="og:image" content={og_image} />}
        {og_image && (
          <meta property="og:image:width" content={og_image_width} />
        )}
        {og_image && (
          <meta property="og:image:height" content={og_image_height} />
        )}
        <meta property="og:title" content={og_title} />
        <meta property="og:description" content={og_description} />
        <meta property="fb:app_id" content={fb_app_id} />
        <meta property="og:type" content={og_type} />
        {Object.entries(metaProps).map(([property, content]) => {
          // console.log("🥐  meta", property, content);
          // TODO: fix content & => &amp; conversion on server side render
          // return <meta property={property} content={content} />;
          return <meta property={property} content={content} />;
        })}
        {/* tracking code */}
        {googleSiteVerification && (
          <meta
            name="google-site-verification"
            content={googleSiteVerification}
          />
        )}
        <link rel="apple-touch-icon" href={logoTeal} />
        <link rel="shortcut icon" href={logoTeal} />
      </Head>
      <style>{css}</style>
      <style jsx global>
        {`
          body {
            background: #ffffff;
            margin: 0;
          }
        `}
      </style>
    </div>
  );
};

Meta.propTypes = {
  title: PropTypes.string,
  css: PropTypes.string,
  description: PropTypes.string,
  image: PropTypes.string,
  metaProps: PropTypes.object
};

Meta.defaultProps = {
  title: null,
  css: "",
  description: "Get inspired, be yourself, judgement free. Join Maverick.",
  image: "https://cdn.genmaverick.com/logo/maverick-privateimage.jpg",
  metaProps: {}
};

export default Meta;
