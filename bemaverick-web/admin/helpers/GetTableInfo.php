<?php

require_once( SLY_ROOT_DIR . '/lib/Sly/View/Helper/GetTableInfo.php' );

class BeMaverick_Admin_View_Helper_GetTableInfo  extends Sly_View_Helper_GetTableInfo
{
    /**
     * Get the column information for passed in column indices
     *
     * @param array $columns
     * @return hash The return hash contains:
     *              ['columnIndex'] = value
     */
    public function getColumnInfo($columns = null)
    {
        $columnInfo = array(
            'tableRowDelete' => array(
                'title' => 'Delete',
                'className' => 'tableRowDelete',
            ),

            'challengeId' => array(
                'title' => 'Id',
                'className' => 'challengeId numeric id',
                'sort' => 'id',
            ),
            'challengeIdWithHiddenInput' => array(
                'title' => 'Id',
                'className' => 'challengeId numeric id',
            ),
            'challengeMainImage' => array(
                'title' => 'Main / Challenge',
                'className' => 'challengeMainImage mainImage',
            ),
            'challengeCardImage' => array(
                'title' => 'Card',
                'className' => 'challengeCardImage cardImage',
            ),
            'challengeTitle' => array(
                'title' => 'Title',
                'className' => 'challengeTitle title',
                'sort' => 'title',
            ),
            'challengeType' => array(
                'title' => 'Type',
                'className' => 'challengeType type',
                'sort' => 'type',
            ),
            'challengeUserUsername' => array(
                'title' => 'User',
                'className' => 'challengeUserUsername username',
                'sort' => 'userUsername',
            ),
            'challengeStartTime' => array(
                'title' => 'Start Time',
                'className' => 'challengeStartTime startTime',
                'sort' => 'startTime',
            ),
            'challengeEndTime' => array(
                'title' => 'End Time',
                'className' => 'challengeEndTime endTime',
                'sort' => 'endTime',
            ),
            'challengeSortOrder' => array(
                'title' => 'Sort Order',
                'className' => 'challengeSortOrder numeric sortOrder',
                'sort' => 'sortOrder',
            ),
            'challengeStatus' => array(
                'title' => 'Status',
                'className' => 'challengeStatus status',
            ),
            'challengeAction' => array(
                'title' => 'Action',
                'className' => 'challengeAction action',
            ),

            'userId' => array(
                'title' => 'Id',
                'className' => 'userId numeric id',
                'sort' => 'id',
            ),
            'userIdWithHiddenInput' => array(
                'title' => 'Id',
                'className' => 'userId numeric id',
            ),
            'userStatus' => array(
                'title' => 'Status',
                'className' => 'userStatus status',
            ),
            'userRevokedReason' => array(
                'title' => 'Revoked Reason',
                'className' => 'userEmailAddress',
            ),
            'userType' => array(
                'title' => 'Type',
                'className' => 'userType',
            ),
            'userUsername' => array(
                'title' => 'Username',
                'className' => 'userUsername username',
            ),
            'userName' => array(
                'title' => 'Name',
                'className' => 'userName',
            ),
            'userAge' => array(
                'title' => 'Age',
                'className' => 'userAge',
                'sort' => 'birthdate',
            ),
            'userParentEmailAddress' => array(
                'title' => 'Parent Email Address',
                'className' => 'userParentEmailAddress',
            ),
            'userEmailAddress' => array(
                'title' => 'Email Address',
                'className' => 'userEmailAddress',
            ),
            'userRegisteredTime' => array(
                'title' => 'Registered Time',
                'className' => 'userRegisteredTime',
                'sort' => 'registeredTimestamp',
            ),
            'userAction' => array(
                'title' => 'Action',
                'className' => 'userAction action',
            ),

            'responseId' => array(
                'title' => 'Id',
                'className' => 'responseId numeric id',
                'sort' => 'id',
            ),
            'responseIdWithHiddenInput' => array(
                'title' => 'Id',
                'className' => 'responseId numeric id',
            ),
            'responseStatus' => array(
                'title' => 'Status',
                'className' => 'responseStatus status',
            ),
            'responseType' => array(
                'title' => 'Media',
                'className' => 'responseType',
            ),
            'postType' => array(
                'title' => 'Post Type',
                'className' => 'postType',
            ),
            'responseVideoThumbnail' => array(
                'title' => 'Thumbnail',
                'className' => 'responseVideoThumbnail videoThumbnail',
            ),
            'responseVideoPlayer' => array(
                'title' => 'Video / Image',
                'className' => 'responseVideoPlayer',
            ),
            'responseUsername' => array(
                'title' => 'Username',
                'className' => 'responseUsername username',
                'sort' => 'username',
            ),
            'responseChallengeTitle' => array(
                'title' => 'Challenge',
                'className' => 'responseChallengeTitle title',
                'sort' => 'challengeTitle',
            ),
            'responseCreatedTimestamp' => array(
                'title' => 'Created Time',
                'className' => 'responseCreatedTimestamp createdTimestamp',
                'sort' => 'createdTimestamp',
            ),
            'responseAction' => array(
                'title' => 'Action',
                'className' => 'responseAction action',
            ),
            'responseEditFeaturedSortOrder' => array(
                'title' => 'Featured Sort Order',
                'className' => 'responseEditFeaturedSortOrder sortOrder',
            ),
            'responseEditFavorite' => array(
                'title' => '<input type="checkbox" class="select-all" data-action-selector=".responseEditFavorite input"> Favorite',
                'className' => 'responseEditFavorite',
            ),
            'responseEditBadge' => array(
                'title' => 'Badge',
                'className' => 'responseEditBadge',
            ),
            'responseHideFromStreams' => array(
                'title' => 'Visibility',
                'className' => 'responseHideFromStreams',
            ),

            'mentorId' => array(
                'title' => 'Id',
                'className' => 'mentorId numeric',
                'sort' => 'id',
            ),
            'mentorProfileImage' => array(
                'title' => 'Image',
                'className' => 'mentorProfile image',
            ),
            'mentorFirstName' => array(
                'title' => 'First Name',
                'className' => 'mentorFirstName',
            ),
            'mentorLastName' => array(
                'title' => 'Last Name',
                'className' => 'mentorLastName',
            ),
            'mentorShortDescription' => array(
                'title' => 'Short Description',
                'className' => 'mentorShortDescription',
            ),
            'mentorAction' => array(
                'title' => 'Action',
                'className' => 'mentorAction action',
            ),
            'kidBio' => array(
                'title' => 'Bio',
                'className' => 'kidBio',
            ),
            'kidProfileImage' => array(
                'title' => 'Image',
                'className' => 'kidProfileImage profileImage',
            ),
            'kidAction' => array(
                'title' => 'Action',
                'className' => 'mentorProfile image',
            ),

            'parentAction' => array(
                'title' => 'Action',
                'className' => 'parentAction action',
            ),

            'contentId' => array(
                'title' => 'Id',
                'className' => 'contentId numeric',
                'sort' => 'id',
            ),
            'contentVideoThumbnail' => array(
                'title' => 'Thumbnail',
                'className' => 'contentMainImage mainImage',
            ),
            'contentTitle' => array(
                'title' => 'Title',
                'className' => 'contentTitle',
                'sort' => 'title',
            ),
            'contentUsername' => array(
                'title' => 'User',
                'className' => 'contentUserUsername',
                'sort' => 'userUsername',
            ),
            'contentType' => array(
                'title' => 'Type',
                'className' => 'contentType',
                'sort' => 'startTime',
            ),
            'contentStatus' => array(
                'title' => 'Status',
                'className' => 'contentStatus',
            ),
            'contentAction' => array(
                'title' => 'Action',
                'className' => 'contentAction action',
            ),
            'streamId' => array(
                'title' => 'ID',
                'className' => 'streamId numeric id',
                'sort' => 'id',
            ),
            'streamIdWithHiddenInput' => array(
                'title' => 'ID',
                'className' => 'streamId numeric id',
                'sort' => 'id',
            ),
            'streamStatus' => array(
                'title' => 'Status',
                'className' => 'streamStatus',
                'sort' => 'status',
            ),
            'streamLabel' => array(
                'title' => 'Label',
                'className' => 'streamLabel',
                'sort' => 'label',
            ),
            'streamType' => array(
                'title' => 'Type',
                'className' => 'streamModelType',
                'sort' => 'modelType',
            ),
            'streamModelType' => array(
                'title' => 'Model',
                'className' => 'streamModelType',
                'sort' => 'modelType',
            ),
            'streamAction' => array(
                'title' => '',
                'className' => 'streamAction',
            ),
            'upDown' => array(
                'title' => '',
                'className' => 'upDown',
            ),
            'badgeId' => array(
                'title' => 'ID',
                'className' => 'badgeId',
            ),
            'badgeStatus' => array(
                'title' => 'Status',
                'className' => 'badgeStatus',
            ),
            'badgeName' => array(
                'title' => 'Name',
                'className' => 'badgeName',
            ),
            'badgeColor' => array(
                'title' => 'Color',
                'className' => 'badgeColor',
            ),
            'badgePrimaryImage' => array(
                'title' => '',
                'className' => 'badgePrimaryImage',
            ),
            'badgeSecondaryImage' => array(
                'title' => '',
                'className' => 'badgeSecondaryImage',
            ),
        );

        $columnsToReturn = array();
        if ( $columns ) {
            foreach ( $columns as $column) {
                if ( isset( $columnInfo[$column] ) ) {
                    $columnsToReturn[$column] =  $columnInfo[$column];
                }
            }
            return $columnsToReturn;
        } else {
            return $columnInfo;
        }
    }

    /**
     * Get the column group information
     *
     * @return hash The return hash contains:
     *              ['groupIndex'] = array of values
     */
    public function getColumnGroupInfo()
    {
        $groupInfo = array(
        );

        return $groupInfo;
    }

}
