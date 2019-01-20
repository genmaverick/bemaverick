<?php

require_once( SLY_ROOT_DIR . '/lib/Sly/Input.php' );

/**
 * Class for handling input from the user
 *
 */
class BeMaverick_Input extends Sly_Input
{

    /**
     * @var array
     * @access protected
     */
    protected $_paramValues = array(

        'address' => array(
            'filters' => array( 'StringTrim', 'StripTags' ),
            'validators' => array( array( 'StringLength', 1, 255 ) ),
            'errorStringIds' => array(
                'message' => 'INPUT_INVALID_ADDRESS',
            ),
        ),
        'appKey' => array(
            'filters' => array( 'StringTrim', 'StripTags' ),
            'validators' => array( array( 'StringLength', 1, 255 ) ),
            'errorStringIds' => array(
                'message' => 'INPUT_INVALID_APP_KEY',
            ),
        ),
        'badgeId' => array(
            'filters' => array( 'StringTrim', 'StripTags' ),
            'validators' => array( 'Digits' ),
            'errorStringIds' => array(
                'message' => 'INPUT_INVALID_BADGE_ID',
            ),
        ),
        'birthdate' => array(
            'filters' => array( 'StringTrim', 'StripTags' ),
            'validators' => array( array( 'Regex', '/^(\d\d\d\d-\d\d-\d\d)$/' ) ),
            'errorStringIds' => array(
                'message' => 'INPUT_INVALID_BIRTHDATE',
            ),
        ),
        'challengeId' => array(
            'filters' => array( 'StringTrim', 'StripTags' ),
            'validators' => array( 'Digits' ),
            'errorStringIds' => array(
                'message' => 'INPUT_INVALID_CHALLENGE_ID',
            ),
        ),
        'challengeStatus' => array(
            'filters' => array( 'StringTrim', 'StripTags' ),
            'validators' => array( array( 'Regex', '/^(draft|published|hidden|deleted)$/' ) ),
            'errorStringIds' => array(
                'message' => 'INPUT_INVALID_CHALLENGE_STATUS',
            ),
        ),
        'challengeType' => array(
            'filters' => array( 'StringTrim', 'StripTags' ),
            'validators' => array( array( 'Regex', '/^(video|image)$/' ) ),
            'errorStringIds' => array(
                'message' => 'INPUT_INVALID_CHALLENGE_TYPE',
            ),
        ),
        'challengeTitle' => array(
            'filters' => array( 'StringTrim', 'StripTags' ),
            'validators' => array( array( 'StringLength', 1, 1000 ) ),
            'errorStringIds' => array(
                'message' => 'INPUT_INVALID_CHALLENGE_TITLE',
            ),
        ),
        'code' => array(
            'filters' => array( 'StringTrim', 'StripTags' ),
            'validators' => array( array( 'StringLength', 1, 1000 ) ),
            'errorStringIds' => array(
                'message' => 'INPUT_INVALID_CODE',
            ),
        ),
        'confirmPassword' => array(
            'filters' => array( 'StringTrim', 'StripTags' ),
            'validators' => array( array( 'StringLength', 6, 255 ) ),
            'errorStringIds' => array(
                'message' => 'INPUT_INVALID_CONFIRM_PASSWORD',
            ),
        ),
        'consentCollect' => array(
            'filters' => array( 'StringTrim', 'StripTags' ),
            'validators' => array( 'Digits' ),
            'errorStringIds' => array(
                'message' => 'INPUT_INVALID_CONSENT_COLLECT',
            ),
        ),
        'consentShare' => array(
            'filters' => array( 'StringTrim', 'StripTags' ),
            'validators' => array( 'Digits' ),
            'errorStringIds' => array(
                'message' => 'INPUT_INVALID_CONSENT_SHARE',
            ),
        ),
        'contentId' => array(
            'filters' => array( 'StringTrim', 'StripTags' ),
            'validators' => array( 'Digits' ),
            'errorStringIds' => array(
                'message' => 'INPUT_INVALID_CONTENT_ID',
            ),
        ),
        'contentStatus' => array(
            'filters' => array( 'StringTrim', 'StripTags' ),
            'validators' => array( array( 'Regex', '/^(draft|active|inactive|deleted)$/' ) ),
            'errorStringIds' => array(
                'message' => 'INPUT_INVALID_CONTENT_STATUS',
            ),
        ),
        'contentTitle' => array(
            'filters' => array( 'StringTrim', 'StripTags' ),
            'validators' => array( array( 'StringLength', 1, 1000 ) ),
            'errorStringIds' => array(
                'message' => 'INPUT_INVALID_CONTENT_TITLE',
            ),
        ),
        'currentPassword' => array(
            'filters' => array( 'StringTrim', 'StripTags' ),
            'validators' => array( array( 'StringLength', 1, 255 ) ),
            'errorStringIds' => array(
                'message' => 'INPUT_INVALID_CURRENT_PASSWORD',
            ),
        ),
        'date' => array(
            'filters' => array( 'StringTrim', 'StripTags' ),
            'validators' => array( array( 'Regex', '/^(\d\d\d\d-\d\d-\d\d)$/' ) ),
            'errorStringIds' => array(
                'message' => 'INPUT_INVALID_DATE',
            ),
        ),
        'emailAddress' => array(
            'filters' => array( 'StringTrim', 'StripTags' ),
            'validators' => array( 'EmailAddress' ),
            'errorStringIds' => array(
                'message' => 'INPUT_INVALID_EMAIL_ADDRESS',
            ),
        ),
        'notifications' => array(
            'filters' => array( 'StringTrim', 'StripTags' ),
            'validators' => array( array( 'StringLength', 1, 255 ) ),
            'errorStringIds' => array(
                'message' => 'INPUT_INVALID_NOTIFICATIONS',
            ),
        ),
        'endTime' => array(
            'filters' => array( 'StringTrim', 'StripTags' ),
            'validators' => array( array( 'StringLength', 1, 255 ) ),
            'errorStringIds' => array(
                'message' => 'INPUT_INVALID_END_TIME',
            ),
        ),
        'fbAccessToken' => array(
            'filters' => array( 'StringTrim', 'StripTags' ),
            'validators' => array( array( 'StringLength', 1, 1000 ) ),
            'errorStringIds' => array(
                'message' => 'INPUT_INVALID_FACEBOOK_ACCESS_TOKEN',
            ),
        ),
        'featuredType' => array(
            'filters' => array( 'StringTrim', 'StripTags' ),
            // 'validators' => array( array( 'Regex', '/^(maverick-stream|challenge-stream|maverick-user)$/' ) ),
            'validators' => array( array( 'StringLength', 1, 255 ) ),
            'errorStringIds' => array(
                'message' => 'INPUT_INVALID_FEATURED_TYPE',
            ),
        ),
        'filename' => array(
            'filters' => array( 'StringTrim', 'StripTags' ),
            'validators' => array( array( 'StringLength', 1, 255 ) ),
            'errorStringIds' => array(
                'message' => 'INPUT_INVALID_FILENAME',
            ),
        ),
        'firstName' => array(
            'filters' => array( 'StringTrim', 'StripTags' ),
            'validators' => array( array( 'StringLength', 1, 255 ) ),
            'errorStringIds' => array(
                'message' => 'INPUT_INVALID_FIRST_NAME',
            ),
        ),
        'followingAction' => array(
            'filters' => array( 'StringTrim', 'StripTags' ),
            'validators' => array( array( 'Regex', '/^(follow|unfollow)$/' ) ),
            'errorStringIds' => array(
                'message' => 'INPUT_INVALID_FOLLOWING_ACTION',
            ),
        ),
        'followingUserId' => array(
            'filters' => array( 'StringTrim', 'StripTags' ),
            'validators' => array( 'Digits' ),
            'errorStringIds' => array(
                'message' => 'INPUT_INVALID_FOLLOWING_USER_ID',
            ),
        ),
        'followerUserId' => array(
            'filters' => array( 'StringTrim', 'StripTags' ),
            'validators' => array( 'Digits' ),
            'errorStringIds' => array(
                'message' => 'INPUT_INVALID_FOLLOWER_USER_ID',
            ),
        ),
        'imageId' => array(
            'filters' => array( 'StringTrim', 'StripTags' ),
            'validators' => array( 'Digits' ),
            'errorStringIds' => array(
                'message' => 'INPUT_INVALID_IMAGE_ID',
            ),
        ),
        'lastFourSSN' => array(
            'filters' => array( 'StringTrim', 'StripTags' ),
            'validators' => array( 'Digits' ),
            'errorStringIds' => array(
                'message' => 'INPUT_INVALID_LAST_FOUR_SSN',
            ),
        ),
        'lastName' => array(
            'filters' => array( 'StringTrim', 'StripTags' ),
            'validators' => array( array( 'StringLength', 1, 255 ) ),
            'errorStringIds' => array(
                'message' => 'INPUT_INVALID_LAST_NAME',
            ),
        ),
        'mentorId' => array(
            'filters' => array( 'StringTrim', 'StripTags' ),
            'validators' => array( 'Digits' ),
            'errorStringIds' => array(
                'message' => 'INPUT_INVALID_MENTOR_ID',
            ),
        ),
        'message' => array(
            'filters' => array( 'StringTrim', 'StripTags' ),
            'validators' => array( array( 'StringLength', 1, 5000 ) ),
            'errorStringIds' => array(
                'message' => 'INPUT_INVALID_MESSAGE',
            ),
        ),
        'newPassword' => array(
            'filters' => array( 'StringTrim', 'StripTags' ),
            'validators' => array( array( 'StringLength', 6, 255 ) ),
            'errorStringIds' => array(
                'message' => 'INPUT_INVALID_NEW_PASSWORD',
            ),
        ),
        'parentEmailAddress' => array(
            'filters' => array( 'StringTrim', 'StripTags' ),
            'validators' => array( 'EmailAddress' ),
            'errorStringIds' => array(
                'message' => 'INPUT_INVALID_PARENT_EMAIL_ADDRESS',
            ),
        ),
        'password' => array(
            'filters' => array( 'StringTrim', 'StripTags' ),
            'validators' => array( array( 'StringLength', 6, 255 ) ),
            'errorStringIds' => array(
                'message' => 'INPUT_INVALID_PASSWORD',
            ),
        ),
        'phoneNumber' => array(
            'filters' => array( 'StringTrim', 'StripTags' ),
            'validators' => array( array( 'StringLength', 1, 25 ) ),
            'errorStringIds' => array(
                'message' => 'INPUT_INVALID_PHONE_NUMBER',
            ),
        ),
        'responseId' => array(
            'filters' => array( 'StringTrim', 'StripTags' ),
            'validators' => array( 'Digits' ),
            'errorStringIds' => array(
                'message' => 'INPUT_INVALID_RESPONSE_ID',
            ),
        ),
        'responseStatus' => array(
            'filters' => array( 'StringTrim', 'StripTags' ),
            'validators' => array( array( 'Regex', '/^(draft|active|inactive|deleted)$/' ) ),
            'errorStringIds' => array(
                'message' => 'INPUT_INVALID_RESPONSE_STATUS',
            ),
        ),
        'responseType' => array(
            'filters' => array( 'StringTrim', 'StripTags' ),
            'validators' => array( array( 'Regex', '/^(video|image)$/' ) ),
            'errorStringIds' => array(
                'message' => 'INPUT_INVALID_RESPONSE_TYPE',
            ),
        ),
        'postType' => array(
            'filters' => array( 'StringTrim', 'StripTags' ),
            'validators' => array( array( 'Regex', '/^(response|content)$/' ) ),
            'errorStringIds' => array(
                'message' => 'INPUT_INVALID_POST_TYPE',
            ),
        ),
        'contentType' => array(
            'filters' => array( 'StringTrim', 'StripTags' ),
            'validators' => array( array( 'Regex', '/^(video|image|challenge|response|post|user)$/' ) ),
            'errorStringIds' => array(
                'message' => 'INPUT_INVALID_CONTENT_TYPE',
            ),
        ),
        'favoriteAction' => array(
            'filters' => array( 'StringTrim', 'StripTags' ),
            'validators' => array( array( 'Regex', '/^(favorite|unfavorite)$/' ) ),
            'errorStringIds' => array(
                'message' => 'INPUT_INVALID_FAVORITE_ACTION',
            ),
        ),
        'saveAction' => array(
            'filters' => array( 'StringTrim', 'StripTags' ),
            'validators' => array( array( 'Regex', '/^(add|remove)$/' ) ),
            'errorStringIds' => array(
                'message' => 'INPUT_INVALID_SAVE_ACTION',
            ),
        ),
        'sortOrder' => array(
            'filters' => array( 'StringTrim', 'StripTags' ),
            'validators' => array( array( 'StringLength', 1, 5 ) ),
            'errorStringIds' => array(
                'message' => 'INPUT_INVALID_SORT_ORDER',
            ),
        ),
        'successPage' => array(
            'filters' => array( 'StringTrim', 'StripTags' ),
            'validators' => array( array( 'StringLength', 1, 255 ) ),
            'errorStringIds' => array(
                'message' => 'INPUT_INVALID_SUCCESS_PAGE',
            ),
        ),
        'startTime' => array(
            'filters' => array( 'StringTrim', 'StripTags' ),
            'validators' => array( array( 'StringLength', 1, 255 ) ),
            'errorStringIds' => array(
                'message' => 'INPUT_INVALID_START_TIME',
            ),
        ),
        'account' => array(
            'filters' => array( 'StringTrim', 'StripTags' ),
            'validators' => array( array( 'StringLength', 1, 255 ) ),
            'errorStringIds' => array(
                'message' => 'INPUT_INVALID_ACCOUNT',
            ),
        ),
        'timestamp' => array(
            'filters' => array( 'StringTrim', 'StripTags' ),
            'validators' => array( 'Digits' ),
            'errorStringIds' => array(
                'message' => 'INPUT_INVALID_TIMESTAMP',
            ),
        ),
        'transcriptionText' => array(
            'filters' => array( 'StringTrim', 'StripTags' ),
            'validators' => array( array( 'StringLength', 0, 5000 ) ),
            'errorStringIds' => array(
                'message' => 'INPUT_INVALID_TRANSCRIPTION_TEXT',
            ),
        ),
        'twitterAccessToken' => array(
            'filters' => array( 'StringTrim', 'StripTags' ),
            'validators' => array( array( 'StringLength', 1, 255 ) ),
            'errorStringIds' => array(
                'message' => 'INPUT_INVALID_TWITTER_ACCESS_TOKEN',
            ),
        ),
        'twitterAccessTokenSecret' => array(
            'filters' => array( 'StringTrim', 'StripTags' ),
            'validators' => array( array( 'StringLength', 1, 255 ) ),
            'errorStringIds' => array(
                'message' => 'INPUT_INVALID_TWITTER_ACCESS_TOKEN_SECRET',
            ),
        ),
        'username' => array(
            'filters' => array( 'StringTrim', 'StripTags' ),
            'validators' => array( array( 'Regex', '/^[A-Za-z0-9\._\-]{4,20}$/' ) ),
            'errorStringIds' => array(
                'message' => 'INPUT_INVALID_USERNAME',
            ),
        ),
        'userId' => array(
            'filters' => array( 'StringTrim', 'StripTags' ),
            // 'validators' => array( 'Digits' ),
            'validators' => array( array( 'StringLength', 1, 255 ) ),
            'errorStringIds' => array(
                'message' => 'INPUT_INVALID_USER_ID',
            ),
        ),
        'userType' => array(
            'filters' => array( 'StringTrim', 'StripTags' ),
            'validators' => array( array( 'Regex', '/^(kid|mentor|parent)$/' ) ),
            'errorStringIds' => array(
                'message' => 'INPUT_INVALID_USER_TYPE',
            ),
        ),
        'userStatus' => array(
            'filters' => array( 'StringTrim', 'StripTags' ),
            'validators' => array( array( 'Regex', '/^(draft|active|inactive|revoked|deleted)$/' ) ),
            'errorStringIds' => array(
                'message' => 'INPUT_INVALID_USER_STATUS',
            ),
        ),
        'userRevokedReason' => array(
            'filters' => array( 'StringTrim', 'StripTags' ),
            'validators' => array( array( 'Regex', '/^$|^(inappropriate|harassment|notdemo|parental|other)$/' ) ),
            'errorStringIds' => array(
                'message' => 'INPUT_INVALID_USER_REVOKED_REASON',
            ),
        ),
        'zipCode' => array(
            'filters' => array( 'StringTrim', 'StripTags' ),
            'validators' => array( 'Digits' ),
            'errorStringIds' => array(
                'message' => 'INPUT_INVALID_ZIP_CODE',
            ),
        ),
        'childUserId' => array(
            'filters' => array( 'StringTrim', 'StripTags' ),
            'validators' => array( 'Digits' ),
            'errorStringIds' => array(
                'message' => 'INPUT_INVALID_USER_ID',
            ),
        ),
        'jobId' => array(
            'filters' => array( 'StringTrim', 'StripTags' ),
            'validators' => array( array( 'StringLength', 1, 255 ) ),
            'errorStringIds' => array(
                'message' => 'INPUT_INVALID_JOB_ID',
            ),
        ),
        'jobStatus' => array(
            'filters' => array( 'StringTrim', 'StripTags' ),
            'validators' => array( array( 'StringLength', 1, 255 ) ),
            'errorStringIds' => array(
                'message' => 'INPUT_INVALID_JOB_STATUS',
            ),
        ),
        'playlistname' => array(
            'filters' => array( 'StringTrim', 'StripTags' ),
            'validators' => array( array( 'StringLength', 1, 255 ) ),
            'errorStringIds' => array(
                'message' => 'INPUT_INVALID_PLAYLIST_NAME',
            ),
        ),
        'preferences' => array(
            'filters' => array( 'StringTrim', 'StripTags' ),
            'validators' => array( ),
            'errorStringIds' => array(
                'message' => 'INPUT_INVALID_USER_PREFERENCES',
            ),
        ),
        'displayLimit' => array(
            'filters' => array( 'StringTrim', 'StripTags' ),
            'validators' => array( 'Digits' ),
            'errorStringIds' => array(
                'message' => 'INPUT_INVALID_DISPLAY_LIMIT',
            ),
        ),
        'delay' => array(
            'filters' => array( 'StringTrim', 'StripTags' ),
            'validators' => array( 'Digits' ),
            'errorStringIds' => array(
                'message' => 'INPUT_INVALID_DELAY',
            ),
        ),
        'rotateFrequency' => array(
            'filters' => array( 'StringTrim', 'StripTags' ),
            'validators' => array( 'Digits' ),
            'errorStringIds' => array(
                'message' => 'INPUT_INVALID_ROTATE_FREQUENCY',
            ),
        ),
        'rotateCount' => array(
            'filters' => array( 'StringTrim', 'StripTags' ),
            'validators' => array( 'Digits' ),
            'errorStringIds' => array(
                'message' => 'INPUT_INVALID_ROTATE_COUNT',
            ),
        ),
        'rotateOnSave' => array(
            'filters' => array( 'StringTrim', 'StripTags' ),
            'validators' => array( array( 'StringLength', 1, 255 ) ),
            'errorStringIds' => array(
                'message' => 'INPUT_INVALID_REORDER_ON_SAVE',
            ),
        ),
        'deeplinkModelType' => array(
            'filters' => array( 'StringTrim', 'StripTags' ),
            'validators' => array( array( 'StringLength', 1, 255 ) ),
            'errorStringIds' => array(
                'message' => 'INPUT_INVALID_DEEPLINK_MODEL_TYPE',
            ),
        ),
        'deeplinkModelId' => array(
            'filters' => array( 'StringTrim', 'StripTags' ),
            'validators' => array( 'Digits' ),
            'errorStringIds' => array(
                'message' => 'INPUT_INVALID_DEEPLINK_MODEL_ID',
            ),
        ),
        'deeplinkUri' => array(
            'filters' => array( 'StringTrim', 'StripTags' ),
            'validators' => array( array( 'StringLength', 1, 255 ) ),
            'errorStringIds' => array(
                'message' => 'INPUT_INVALID_DEEP_LINK_URI',
            ),
        ),
        'label' => array(
            'filters' => array( 'StringTrim', 'StripTags' ),
            'validators' => array( array( 'StringLength', 1, 255 ) ),
            'errorStringIds' => array(
                'message' => 'INPUT_INVALID_LABEL',
            ),
        ),
        'streamId' => array(
            'filters' => array( 'StringTrim', 'StripTags' ),
            'validators' => array( 'Digits' ),
            'errorStringIds' => array(
                'message' => 'INPUT_INVALID_STREAM_ID',
            ),
        ),
        'streamType' => array(
            'filters' => array( 'StringTrim', 'StripTags' ),
            'validators' => array( array( 'StringLength', 1, 255 ) ),
            'errorStringIds' => array(
                'message' => 'INPUT_INVALID_STREAM_TYPE',
            ),
        ),
        'moderationStatus' => array(
            'filters' => array( 'StringTrim', 'StripTags' ),
            'validators' => array( array( 'Regex', '/^(allow|authorOnly|replace|queuedForApproval|reject|error)$/' ) ),
            'errorStringIds' => array(
                'message' => 'INPUT_INVALID_MODERATION_STATUS',
            ),
        ),
        'stagger' => array(
            'filters' => array( 'StringTrim', 'StripTags' ),
            'validators' => array( array( 'StringLength', 1, 5 ) ),
            'errorStringIds' => array(
                'message' => 'INPUT_INVALID_STAGGER',
            ),
        )
    );
}

?>
