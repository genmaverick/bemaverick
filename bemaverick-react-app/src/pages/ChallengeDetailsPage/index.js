import React from "react";
import PropTypes from "prop-types";
import SharePage from "../../layouts/SharePage";
import Section from "../../components/Section";
import ChallengeDetails from "../../components/ChallengeDetails";
import { pinkBackgroundLight } from "../../assets/colors";
import Maverick from "../../utils/maverick";
import getMetaProps from "./getMetaProps";

const ChallengeDetailsPage = ({ challenge, user, video, metaProps }) => (
  <SharePage title={challenge.title} metaProps={metaProps}>
    <Section background={pinkBackgroundLight} flexGrow="1">
      <ChallengeDetails challenge={challenge} user={user} video={video} />
    </Section>
  </SharePage>
);
ChallengeDetailsPage.getInitialProps = async ({ query }) => {
  try {
    const { challengeId } = query;
    const response = await Maverick.getChallenge({ challengeId });
    // console.log(`Maverick.getChallenge(${challengeId}).response`, response);
    const challenge = response.data.challenges[challengeId];
    const user = response.data.users[challenge.userId];
    const video =
      challenge.videoId > 0 ? response.data.videos[challenge.videoId] : null;

    const metaProps = getMetaProps({ challenge, user, video });

    // console.log('video', video);

    return {
      // data: response.data,
      challenge,
      user,
      video,
      metaProps
    };
  } catch (error) {
    console.log("error", error);
    return { content: "", loading: false, error: error.toString() };
  }
};
ChallengeDetailsPage.propTypes = {
  challenge: PropTypes.object,
  user: PropTypes.object,
  video: PropTypes.object,
  metaProps: PropTypes.object
};

ChallengeDetailsPage.defaultProps = {
  challenge: {
    title: "...",
    description: "...",
    peekComments: { meta: { count: 0 } },
    numResponses: 0
  },
  user: false,
  video: false,
  metaProps: {}
};

export default ChallengeDetailsPage;
