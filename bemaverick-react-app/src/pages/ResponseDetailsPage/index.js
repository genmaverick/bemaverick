import React from 'react';
import PropTypes from 'prop-types';
import SharePage from '../../layouts/SharePage';
import Section from '../../components/Section';
import ResponseDetails from '../../components/ResponseDetails';
import { pinkBackgroundLight } from '../../assets/colors';
import Maverick from '../../utils/maverick';

const ResponseDetailsPage = ({
  response, challenge, user, video,
}) => (
  <SharePage title={`Post by ${user.username}`}>
    <Section background={pinkBackgroundLight}>
      <ResponseDetails response={response} challenge={challenge} user={user} video={video} />
    </Section>
  </SharePage>
);

ResponseDetailsPage.getInitialProps = async ({ query }) => {
  try {
    const { responseId } = query;
    const res = await Maverick.getResponse({ responseId });
    const response = res.data.responses[responseId];
    const challenge = response.challengeId ? res.data.challenges[response.challengeId] : null;
    const user = res.data.users[response.userId];
    const video = response.videoId > 0 ? res.data.videos[response.videoId] : null;

    return {
      response,
      challenge,
      user,
      video,
    };
  } catch (error) {
    console.log('error', error);
    return { content: '', loading: false, error: error.toString() };
  }
};
ResponseDetailsPage.propTypes = {
  response: PropTypes.object,
  challenge: PropTypes.object,
  user: PropTypes.object,
  video: PropTypes.object,
};

ResponseDetailsPage.defaultProps = {
  response: {
    title: '...',
    description: '...',
    peekComments: { meta: { count: 0 } },
    numResponses: 0,
  },
  challenge: null,
  user: false,
  video: false,
};

export default ResponseDetailsPage;
