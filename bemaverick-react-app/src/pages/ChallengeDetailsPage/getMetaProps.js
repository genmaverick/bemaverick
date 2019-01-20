import get from "lodash/get";

const getMetaProps = ({ challenge, user, video }) => {
  const baseUrl = process.env.MAVERICK_BASE_URL;
  const props = {};

  // console.log("getMetaProps.challenge", challenge);
  // console.log("getMetaProps.user", user);
  // console.log("getMetaProps.video", video);
  // console.log("baseUrl", baseUrl);
  // console.log("🔔  getMetaProps.js::challenge", challenge);

  const imageUrl =
    challenge.mainImageUrl ||
    challenge.imageUrl ||
    challenge.cardImageUrl ||
    null;

  props["og:description"] = get(challenge, "description", "");
  props["og:url"] = `${baseUrl}/challenges/${get(challenge, "challengeId")}`;

  if (challenge.challengeType === "video" && video) {
    props["og:type"] = "video.other";
    props["og:video:url"] = video.videoUrl || null;
    props["og:video:secure_url"] = video.videoUrl || null;
    props["og:video:type"] = "video/mp4";
    props["og:video:width"] = video.width || 1080;
    props["og:video:height"] = video.height || 1440;
  }

  // console.log("challenge.mainImageUrl", challenge.mainImageUrl);
  props["og:image"] = imageUrl;
  props["og:image:url"] = imageUrl;
  props["og:image:width"] = 1080;
  props["og:image:height"] = 1440;

  // Twitter
  props["twitter:card"] = "summary";
  props["twitter:site"] = "@genmaverick";
  props["twitter:title"] = get(challenge, "title", null);
  props["twitter:description"] = props["og:description"];
  props["twitter:image"] = imageUrl;

  // Escape URL strings
  // props["og:image"] = props["og:image"].replace("&", "\\&");
  // props["twitter:image"] = props["og:image"];
  // props["og:image:url"] = props["og:image"];

  // console.log("🍋  getMetaProps::props", props);

  return props;
};

export default getMetaProps;
