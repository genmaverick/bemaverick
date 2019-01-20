import React from 'react';
import PropTypes from 'prop-types';
import H1 from '../common/H1/contentDetails';
import P from '../common/P';
import A from '../common/A';
import MediaCardFull from '../MediaCardFull';
import AuthorHeadline from '../AuthorHeadline';
import ActivityIndicator from '../ActivityIndicator';
import DownloadAppBlock from '../DownloadAppBlock';

const ResponseDetails = ({
  response, challenge, user, video,
}) => {
  const commentsTotal = response.peekComments.meta.count; // challenge.comments.total || 0;
  const responsesTotal = response.numResponses || 0; // challenge.responses.total || 0;
  const {
    username,
    bio,
    profileImageUrls: { medium: avatar },
  } = user;
  const videoUrl = video !== null ? video.videoUrl || false : false; // this is ugly
  const imageUrl = response.mainImageUrl || response.imageUrl;

  let title = null;
  if (challenge) {
    const challengeTitle = (challenge && challenge.title && challenge.title !== ' ') ? challenge.title : 'This Challenge';
    const challengeUrl = `/challenge/${challenge.challengeId}`;
    title = <H1>Response To <A route={challengeUrl}>{challengeTitle}</A></H1>;
  }
  return (
    <MediaCardFull image={imageUrl} video={videoUrl}>
      {user && <AuthorHeadline username={username} bio={bio} avatar={avatar} />}
      {title}
      <P large>{response.description}</P>
      <ActivityIndicator comments={commentsTotal} responses={responsesTotal} />
      <DownloadAppBlock />
    </MediaCardFull>
  );
};
ResponseDetails.propTypes = {
  response: PropTypes.object.isRequired,
  challenge: PropTypes.object,
  user: PropTypes.object,
  video: PropTypes.object,
};

ResponseDetails.defaultProps = {
  challenge: null,
  user: false,
  video: false,
};

export default ResponseDetails;
