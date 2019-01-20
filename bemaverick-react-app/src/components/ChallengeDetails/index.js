import React from 'react';
import PropTypes from 'prop-types';
import H1 from '../common/H1/contentDetails';
import P from '../common/P';
import MediaCardFull from '../MediaCardFull';
import AuthorHeadline from '../AuthorHeadline';
import ActivityIndicator from '../ActivityIndicator';
import DownloadAppBlock from '../DownloadAppBlock';

const ChallengeDetails = ({ challenge, user, video }) => {
  // console.log('ChallengeDetails.challenge', challenge);
  // console.log('ChallengeDetails.user', user);
  const commentsTotal = challenge.peekComments.meta.count; // challenge.comments.total || 0;
  const responsesTotal = challenge.numResponses || 0; // challenge.responses.total || 0;
  const {
    username,
    bio,
    profileImageUrls: { medium: avatar },
  } = user;
  const videoUrl = video !== null ? video.videoUrl || false : false; // this is ugly

  const imageUrl = challenge.mainImageUrl || challenge.imageUrl;
  return (
    <MediaCardFull image={imageUrl} video={videoUrl}>
      {user && <AuthorHeadline username={username} bio={bio} avatar={avatar} />}
      <H1>{challenge.title}</H1>
      <P large>{challenge.description}</P>
      <ActivityIndicator comments={commentsTotal} responses={responsesTotal} />
      <DownloadAppBlock />
    </MediaCardFull>
  );
};
ChallengeDetails.propTypes = {
  challenge: PropTypes.object.isRequired,
  user: PropTypes.object,
  video: PropTypes.object,
};

ChallengeDetails.defaultProps = {
  user: false,
  video: false,
};

export default ChallengeDetails;
