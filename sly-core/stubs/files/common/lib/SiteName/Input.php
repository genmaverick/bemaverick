<?php

require_once( SLY_ROOT_DIR . '/lib/Sly/Input.php' );

/**
 * Class for handling input from the user
 *
 */
class __SLY_CLASS_PREFIX___Input extends Sly_Input
{

    /**
     * @var array
     * @access protected
     */
    protected $_paramValues = array(
        'accessToken' => array(
            'filters' => array( 'StringTrim', 'StripTags' ),
            'validators' => array( array( 'StringLength', 1, 255 ) ),
            'errorStringIds' => array(
                'message' => 'INPUT_INVALID_ACCESS_TOKEN',
            ),
        ),
        'deviceOS' => array(
            'filters' => array( 'StringTrim', 'StripTags' ),
            'validators' => array( array( 'Regex', '/^(ios|android)$/' ) ),
            'errorStringIds' => array(
                'message' => 'INPUT_INVALID_DEVICE_OS',
            ),
        ),
        'deviceToken' => array(
            'filters' => array( 'StringTrim', 'StripTags' ),
            'validators' => array( array( 'StringLength', 1, 255 ) ),
            'errorStringIds' => array(
                'message' => 'INPUT_INVALID_DEVICE_TOKEN',
            ),
        ),
        'facebookAccessToken' => array(
            'filters' => array( 'StringTrim', 'StripTags' ),
            'validators' => array( array( 'StringLength', 1, 255 ) ),
            'errorStringIds' => array(
                'message' => 'INPUT_INVALID_FACEBOOK_ACCESS_TOKEN',
            ),
        ),
        'gameId' => array(
            'filters' => array( 'StringTrim', 'StripTags' ),
            'validators' => array( 'Digits' ),
            'errorStringIds' => array(
                'message' => 'INPUT_INVALID_GAME_ID',
            ),
        ),
        'numMoves' => array(
            'filters' => array( 'StringTrim', 'StripTags' ),
            'validators' => array( 'Digits' ),
            'errorStringIds' => array(
                'message' => 'INPUT_INVALID_NUM_MOVES',
            ),
        ),
        'opponentFacebookUserId' => array(
            'filters' => array( 'StringTrim', 'StripTags' ),
            'validators' => array( 'Digits' ),
            'errorStringIds' => array(
                'message' => 'INPUT_INVALID_OPPONENT_FACEBOOK_USER_ID',
            ),
        ),
        'opponentUserId' => array(
            'filters' => array( 'StringTrim', 'StripTags' ),
            'validators' => array( 'Digits' ),
            'errorStringIds' => array(
                'message' => 'INPUT_INVALID_OPPONENT_USER_ID',
            ),
        ),
        'puzzleId' => array(
            'filters' => array( 'StringTrim', 'StripTags' ),
            'validators' => array( 'Digits' ),
            'errorStringIds' => array(
                'message' => 'INPUT_INVALID_PUZZLE_ID',
            ),
        ),
        'puzzleIds' => array(
            'filters' => array( 'StringTrim', 'StripTags' ),
            'validators' => array( 'Digits' ),
            'errorStringIds' => array(
                'message' => 'INPUT_INVALID_PUZZLE_IDS',
            ),
        ),
        'puzzleRating' => array(
            'filters' => array( 'StringTrim', 'StripTags' ),
            'validators' => array( 'Digits' ),
            'errorStringIds' => array(
                'message' => 'INPUT_INVALID_PUZZLE_RATING',
            ),
        ),
        'puzzleSetId' => array(
            'filters' => array( 'StringTrim', 'StripTags' ),
            'validators' => array( 'Digits' ),
            'errorStringIds' => array(
                'message' => 'INPUT_INVALID_PUZZLE_SET_ID',
            ),
        ),
        'puzzleSetName' => array(
            'filters' => array( 'StringTrim', 'StripTags' ),
            'validators' => array( array( 'StringLength', 1, 255 ) ),
            'errorStringIds' => array(
                'message' => 'INPUT_INVALID_PUZZLE_SET_NAME',
            ),
        ),
        'puzzleSetQuip' => array(
            'filters' => array( 'StringTrim', 'StripTags' ),
            'validators' => array( array( 'StringLength', 1, 255 ) ),
            'errorStringIds' => array(
                'message' => 'INPUT_INVALID_PUZZLE_SET_QUIP',
            ),
        ),
        'puzzleSetStatus' => array(
            'filters' => array( 'StringTrim', 'StripTags' ),
            'validators' => array( array( 'StringLength', 1, 255 ) ),
            'errorStringIds' => array(
                'message' => 'INPUT_INVALID_PUZZLE_SET_STATUS',
            ),
        ),
        'puzzleTileIds' => array(
            'filters' => array( 'StringTrim', 'StripTags' ),
            'validators' => array( array( 'StringLength', 1, 255 ) ),
            'errorStringIds' => array(
                'message' => 'INPUT_INVALID_PUZZLE_TILE_IDS',
            ),
        ),
        'puzzleTileRotations' => array(
            'filters' => array( 'StringTrim', 'StripTags' ),
            'validators' => array( array( 'StringLength', 1, 255 ) ),
            'errorStringIds' => array(
                'message' => 'INPUT_INVALID_PUZZLE_TILE_ROTATIONS',
            ),
        ),
        'seconds' => array(
            'filters' => array( 'StringTrim', 'StripTags' ),
            'validators' => array( 'Digits' ),
            'errorStringIds' => array(
                'message' => 'INPUT_INVALID_SECONDS',
            ),
        ),
        'tileId' => array(
            'filters' => array( 'StringTrim', 'StripTags' ),
            'validators' => array( 'Digits' ),
            'errorStringIds' => array(
                'message' => 'INPUT_INVALID_TILE_ID',
            ),
        ),
        'tileSetId' => array(
            'filters' => array( 'StringTrim', 'StripTags' ),
            'validators' => array( 'Digits' ),
            'errorStringIds' => array(
                'message' => 'INPUT_INVALID_TILE_SET_ID',
            ),
        ),
        'tileIds' => array(
            'filters' => array( 'StringTrim', 'StripTags' ),
            'validators' => array( array( 'StringLength', 1, 255 ) ),
            'errorStringIds' => array(
                'message' => 'INPUT_INVALID_TILE_IDS',
            ),
        ),
        'tileColors' => array(
            'filters' => array( 'StringTrim', 'StripTags' ),
            'validators' => array( array( 'StringLength', 1, 1000 ) ),
            'errorStringIds' => array(
                'message' => 'INPUT_INVALID_TILE_COLORS',
            ),
        ),
        'serviceName' => array(
            'filters' => array( 'StringTrim', 'StripTags' ),
            'validators' => array( array( 'StringLength', 1, 255 ) ),
            'errorStringIds' => array(
                'message' => 'INPUT_INVALID_SERVICE_NAME',
            ),
        ),
        'userId' => array(
            'filters' => array( 'StringTrim', 'StripTags' ),
            'validators' => array( 'Digits' ),
            'errorStringIds' => array(
                'message' => 'INPUT_INVALID_USER_ID',
            ),
        ),
    );
}
