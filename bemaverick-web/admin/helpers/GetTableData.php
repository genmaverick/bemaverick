<?php

require_once( SLY_ROOT_DIR . '/lib/Sly/View/Helper/GetTableData.php' );

class BeMaverick_Admin_View_Helper_GetTableData extends Sly_View_Helper_GetTableData
{

    public function getTableData( $items, $columns, $input, $allowDuplicates = false )
    {

        $data = array();
        $i = 0;

        foreach( $items as $item ) {  
        
            if ( ! $item ) {
                continue;
            }
            
            if ( is_array($item) && isset( $item['id'] ) ) {
                $id = $item['id'];
            } else if ( is_scalar( $item ) ) {
                $id = $item;
            } else if ( is_object( $item ) ) {
                $id = $item->getId();
            } else {
                continue;
            }

            $rowIndex = $allowDuplicates ? $i : $id;

            foreach( $columns as $column ) {
                $function = "_$column";
                $data[$rowIndex][$column] = call_user_func( array( $this, $function ), $item, $input );
            }

            $i++;
        }

        return $data;
    }    

    /**
     * Get data for 'tableRowDelete' column
     *
     * @param object $object
     * @param hash $input
     * @return string
     */
    protected function _tableRowDelete( $object, $input )
    {
        return '<div class="delete-button"></div>';
    }

    /**
     * Get data for 'challengeId' column
     *
     * @param BeMaverick_Challenge $challenge
     * @param hash $input
     * @return string
     */
    protected function _challengeId( $challenge, $input )
    {
        return $challenge->getId();
    }

    /**
     * Get data for 'challengeIdWithHidenInput' column
     *
     * @param BeMaverick_Challenge $challenge
     * @param hash $input
     * @return string
     */
    protected function _challengeIdWithHiddenInput( $challenge, $input )
    {
        $html = $challenge->getId();
        $html .= '<input type="hidden" name="challengeIds[]" value="' . $challenge->getId() . '">';

        return $html;
    }

    /**
     * Get data for 'challengeImage' column
     *
     * @param BeMaverick_Challenge $challenge
     * @param hash $input
     * @return string
     */
    protected function _challengeImage( $challenge, $input )
    {
        $imageUrl = $challenge->getImageUrl( 60, 108 );

        if ( ! $imageUrl ) {
            return '';
        }

        $originalImageUrl = $challenge->getImageUrl();

        return '<a href="' . $originalImageUrl . '" target="_blank"><img src="' . $imageUrl . '" width="60" height="108" /></a>';
    }

    /**
     * Get data for 'challengeMainImage' column
     *
     * @param BeMaverick_Challenge $challenge
     * @param hash $input
     * @return string
     */
    protected function _challengeMainImage( $challenge, $input )
    {
        $challengeType = $challenge->getChallengeType();
        if ( $challengeType == BeMaverick_Challenge::CHALLENGE_TYPE_IMAGE ) {
            return $this->_challengeImage( $challenge, $input );
        }

        $mainImageUrl = $challenge->getMainImageUrl( 60, 108 );

        if ( ! $mainImageUrl ) {
            return '';
        }

        $originalMainImageUrl = $challenge->getMainImageUrl();

        return '<a href="' . $originalMainImageUrl . '" target="_blank"><img src="' . $mainImageUrl . '" width="60" height="108" /></a>';
    }

    /**
     * Get data for 'challengeCardImage' column
     *
     * @param BeMaverick_Challenge $challenge
     * @param hash $input
     * @return string
     */
    protected function _challengeCardImage( $challenge, $input )
    {
        $cardImageUrl = $challenge->getCardImageUrl( 108, 60 );

        if ( ! $cardImageUrl ) {
            return '';
        }

        $originalCardImageUrl = $challenge->getCardImageUrl();

        return '<a href="' . $originalCardImageUrl . '" target="_blank"><img src="' . $cardImageUrl . '" width="108" height="60" /></a>';
    }

    /**
     * Get data for 'challengeTitle' column
     *
     * @param BeMaverick_Challenge $challenge
     * @param hash $input
     * @return string
     */
    protected function _challengeTitle( $challenge, $input )
    {
        return $challenge->getTitle();
    }

    /**
     * Get data for 'challengeType' column
     *
     * @param BeMaverick_Challenge $challenge
     * @param hash $input
     * @return string
     */
    protected function _challengeType( $challenge, $input )
    {
        $challengeType = $challenge->getChallengeType();
        return $challengeType.'';
    }

    /**
     * Get data for 'challengeMentorName' column
     *
     * @param BeMaverick_Challenge $challenge
     * @param hash $input
     * @return string
     */
    protected function _challengeUserUsername( $challenge, $input )
    {
        $user = $challenge->getUser();

        return $user->getUsername();
    }

    /**
     * Get data for 'challengeStartTime' column
     *
     * @param BeMaverick_Challenge $challenge
     * @param hash $input
     * @return string
     */
    protected function _challengeStartTime( $challenge, $input )
    {
        $startTime = $challenge->getStartTime();

        if ( ! $startTime ) {
            return '';
        }

        return Sly_Date::formatDate( $startTime, 'SHORT_MONTH_DAY_YEAR_TIME_TZ' );
    }

    /**
     * Get data for 'challengeEndTime' column
     *
     * @param BeMaverick_Challenge $challenge
     * @param hash $input
     * @return string
     */
    protected function _challengeEndTime( $challenge, $input )
    {
        $endTime = $challenge->getEndTime();

        if ( ! $endTime ) {
            return '';
        }

        return Sly_Date::formatDate( $endTime, 'SHORT_MONTH_DAY_YEAR_TIME_TZ' );
    }

    /**
     * Get data for 'challengeStatus' column
     *
     * @param BeMaverick_Challenge $challenge
     * @param hash $input
     * @return string
     */
    protected function _challengeStatus( $challenge, $input )
    {
        $status = $challenge->getStatus();

        if ( $status == 'published' ) {
            $cssClass = 'label-primary';
        } else if ( $status == 'hidden' ) {
            $cssClass = 'label-danger';
        } else {
            $cssClass = 'label-default';
        }

        return '<span class="label ' . $cssClass . '">'. ucfirst( $status ) . '</span>';
    }

    /**
     * Get data for 'challengeAction' column
     *
     * @param BeMaverick_Challenge $challenge
     * @param hash $input
     * @return string
     */
    protected function _challengeAction( $challenge, $input )
    {

        $params = array(
            'challengeId' => $challenge->getId(),
        );

        $links = array(
            'edit' => array(
                'title' => 'Edit',
                'link' => $this->view->site->getUrl( 'challengeEdit', $params ),
            ),
        );

        return $this->view->linkList( $links );
    }

    /**
     * Get data for 'userId' column
     *
     * @param BeMaverick_User $user
     * @param hash $input
     * @return string
     */
    protected function _userId( $user, $input )
    {
        return $user->getId();
    }

    /**
     * Get data for 'userIdWithHidenInput' column
     *
     * @param BeMaverick_User $user
     * @param hash $input
     * @return string
     */
    protected function _userIdWithHiddenInput( $user, $input )
    {
        $html = $user->getId();
        $html .= '<input type="hidden" name="userIds[]" value="' . $user->getId() . '">';

        return $html;
    }

    /**
     * Get data for 'userStatus' column
     *
     * @param BeMaverick_User $user
     * @param hash $input
     * @return string
     */
    protected function _userStatus( $user, $input )
    {
        $status = $user->getStatus();

        if ( $status == 'draft' ) {
            $cssClass = 'label-default';
        } else if ( $status == 'active' ) {
            $cssClass = 'label-primary';
        } else if ( $status == 'inactive' ) {
            $cssClass = 'label-warning';
        } else if ( $status == 'revoked' ) {
            $cssClass = 'label-danger';
        } else if ( $status == 'deleted' ) {
            $cssClass = 'label-danger';
        }

        return '<span class="label ' . $cssClass . '">'. ucfirst( $status ) . '</span>';
    }

    /**
     * Get data for 'revokedStatus' column
     *
     * @param BeMaverick_User $user
     * @param hash $input
     * @return string
     */
    protected function _userRevokedReason( $user, $input )
    {
        if ( $user->getRevokedReason()) {
            return $user->getRevokedReason();
        }

        return '';
    }

    /**
     * Get data for 'userType' column
     *
     * @param BeMaverick_User $user
     * @param hash $input
     * @return string
     */
    protected function _userType( $user, $input )
    {
        return $user->getUserType();
    }

    /**
     * Get data for 'userUsername' column
     *
     * @param BeMaverick_User $user
     * @param hash $input
     * @return string
     */
    protected function _userUsername( $user, $input )
    {
        return $user->getUsername();
    }

    /**
     * Get data for 'userName' column
     *
     * @param BeMaverick_User $user
     * @param hash $input
     * @return string
     */
    protected function _userName( $user, $input )
    {
        return $user->getFirstName() . ' ' . $user->getLastName();
    }

    /**
     * Get data for 'userAge' column
     *
     * @param BeMaverick_User $user
     * @param hash $input
     * @return string
     */
    protected function _userAge( $user, $input )
    {
        return $user->getAge();
    }

    /**
     * Get data for 'userParentEmailAddress' column
     *
     * @param BeMaverick_User $user
     * @param hash $input
     * @return string
     */
    protected function _userParentEmailAddress( $user, $input )
    {
        if ( $user->getUserType() == BeMaverick_User::USER_TYPE_KID ) {
            return $user->getParentEmailAddress();
        }

        return '';
    }

    /**
     * Get data for 'userEmailAddress' column
     *
     * @param BeMaverick_User $user
     * @param hash $input
     * @return string
     */
    protected function _userEmailAddress( $user, $input )
    {
        return $user->getEmailAddress();
    }

    /**
     * Get data for 'userRegisteredTime' column
     *
     * @param BeMaverick_User $user
     * @param hash $input
     * @return string
     */
    protected function _userRegisteredTime( $user, $input )
    {
        return Sly_Date::formatDate( $user->getRegisteredTimestamp(), 'SHORT_MONTH_DAY_YEAR_TIME_TZ' );
    }

    /**
     * Get data for 'kidProfileImage' column
     *
     * @param BeMaverick_User_Kid $kid
     * @param hash $input
     * @return string
     */
    protected function _kidProfileImage( $kid, $input )
    {
        $profileImage = $kid->getProfileImage();

        if ( ! $profileImage ) {
            return '';
        }

        return '<img src="' . $profileImage->getUrl( 100, 100 ) . '" width="100" height="100">';
    }

    /**
     * Get data for 'kidBio' column
     *
     * @param BeMaverick_User_Kid $kid
     * @param hash $input
     * @return string
     */
    protected function _kidBio( $kid, $input )
    {
        return $kid->getBio();
    }

    /**
     * Get data for 'kidAction' column
     *
     * @param BeMaverick_User $user
     * @param hash $input
     * @return string
     */
    protected function _kidAction( $user, $input )
    {

        $params = array(
            'userId' => $user->getId(),
        );

        $links = array(
            'edit' => array(
                'title' => 'Edit',
                'link' => $this->view->site->getUrl( 'kidEdit', $params ),
            ),
        );

        return $this->view->linkList( $links );
    }

    /**
     * Get data for 'parentAction' column
     *
     * @param BeMaverick_User $user
     * @param hash $input
     * @return string
     */
    protected function _parentAction( $user, $input )
    {

        $params = array(
            'userId' => $user->getId(),
        );

        $links = array(
            'edit' => array(
                'title' => 'Edit',
                'link' => $this->view->site->getUrl( 'parentEdit', $params ),
            ),
        );

        return $this->view->linkList( $links );
    }

    /**
     * Get data for 'responseId' column
     *
     * @param BeMaverick_Response $response
     * @param hash $input
     * @return string
     */
    protected function _responseId( $response, $input )
    {
        return $response->getId();
    }

    /**
     * Get data for 'responseType' column
     *
     * @param BeMaverick_Response $response
     * @param hash $input
     * @return string
     */
    protected function _responseType( $response, $input )
    {
        return $response->getResponseType();
    }

    /**
     * Get data for 'postType' column
     *
     * @param BeMaverick_Response $response
     * @param hash $input
     * @return string
     */
    protected function _postType( $response, $input )
    {
        $postType = $response->getPostType();
        return $response->getPostType();
    }

    /**
     * Get data for 'responseIdWithHidenInput' column
     *
     * @param BeMaverick_Response $response
     * @param hash $input
     * @return string
     */
    protected function _responseIdWithHiddenInput( $response, $input )
    {
        $html = $response->getId();
        $html .= '<input type="hidden" name="responseIds[]" value="' . $response->getId() . '">';

        return $html;
    }

    /**
     * Get data for 'responseVideoThumbnail' column
     *
     * @param BeMaverick_Response $response
     * @param hash $input
     * @return string
     */
    protected function _responseVideoThumbnail( $response, $input )
    {
        $responseType = $response->getResponseType();
        $video = $response->getVideo();
        $image = $response->getImage();

        $html = '';

        if ( $responseType == BeMaverick_Response::RESPONSE_TYPE_VIDEO && $video ) {
            $html = '<img src="' . $video->getThumbnailUrl() . '" width="60" height="108" />';
        } else if ( $responseType == BeMaverick_Response::RESPONSE_TYPE_IMAGE && $image ) {
            $html = '<img src="' . $image->getUrl( 60, 108 ) . '" width="60" height="108" />';
        }

        return $html;
    }

    /**
     * Get data for 'responseVideoPlayer' column
     *
     * @param BeMaverick_Response $response
     * @param hash $input
     * @return string
     */
    protected function _responseVideoPlayer( $response, $input )
    {
        $responseType = $response->getResponseType();

        if ( $responseType == BeMaverick_Response::RESPONSE_TYPE_VIDEO ) {
            $video = $response->getVideo();

            $html = '
                <video playsinline="playsinline" controls poster="' . $video->getThumbnailUrl() . '">
                    <source type="video/mp4" src="'. $video->getVideoUrl() . '">
                </video>
            ';

        } else if ( $responseType == BeMaverick_Response::RESPONSE_TYPE_IMAGE ) {
            $image = $response->getImage();

            $html = '<a href="' . $image->getUrl() . '" target="_blank">';
            $html .= '<img src="' . $image->getUrl( 60, 108 ) . '" width="60" height="108" />';
            $html .= '</a>';
        }

        return $html;
    }

    /**
     * Get data for 'responseUsername' column
     *
     * @param BeMaverick_Response $response
     * @param hash $input
     * @return string
     */
    protected function _responseUsername( $response, $input )
    {
        $user = $response->getUser();

        return $user->getUsername();
    }

    /**
     * Get data for 'responseChallengeTitle' column
     *
     * @param BeMaverick_Response $response
     * @param hash $input
     * @return string
     */
    protected function _responseChallengeTitle( $response, $input )
    {
        $challenge = $response->getChallenge();
        return ( !empty( $challenge ) ) ? $challenge->getTitle() : '';
    }

    /**
     * Get data for 'responseCreatedTimestamp' column
     *
     * @param BeMaverick_Response $response
     * @param hash $input
     * @return string
     */
    protected function _responseCreatedTimestamp( $response, $input )
    {
        $createdTimestamp = $response->getCreatedTimestamp();

        if ( ! $createdTimestamp ) {
            return '';
        }

        return Sly_Date::formatDate( $createdTimestamp, 'SHORT_MONTH_DAY_YEAR_TIME_TZ' );
    }

    /**
     * Get data for 'responseStatus' column
     *
     * @param BeMaverick_Response $response
     * @param hash $input
     * @return string
     */
    protected function _responseStatus( $response, $input )
    {
        $status = $response->getStatus();

        if ( $status == 'draft' ) {
            $cssClass = 'label-default';
        } else if ( $status == 'active' ) {
            $cssClass = 'label-primary';
        } else if ( $status == 'inactive' ) {
            $cssClass = 'label-warning';
        } else if ( $status == 'deleted' ) {
            $cssClass = 'label-danger';
        }

        return '<span class="label ' . $cssClass . '">'. ucfirst( $status ) . '</span>';
    }

    /**
     * Get data for 'responseAction' column
     *
     * @param BeMaverick_Response $response
     * @param hash $input
     * @return string
     */
    protected function _responseAction( $response, $input )
    {
        $params = array(
            'responseId' => $response->getId(),
        );

        $links = array(
            'edit' => array(
                'title' => 'Edit',
                'link' => $this->view->site->getUrl( 'responseEdit', $params ),
            ),
        );

        return $this->view->linkList( $links );
    }

    /**
     * Get data for 'responseEditFavorite' column
     *
     * @param BeMaverick_Response $response
     * @param hash $input
     * @return string
     */
    protected function _responseEditFavorite( $response, $input )
    {
        $formatFormBootstrap = $this->view->formatFormBootstrap2();

        $value = $response->isFavorited() ? 1 : '';

        $formItems = array();
        $formItems[] = $formatFormBootstrap->getCheckboxSimple( 'responseFavorite-' . $response->getId(), '', $value, '' );

        return $formatFormBootstrap->getList( $formItems );
    }

    /**
     * Get data for 'responseEditBadges' column
     *
     * @param BeMaverick_Response $response
     * @param hash $input
     * @return string
     */
    protected function _responseEditBadge( $response, $input )
    {
        $formatFormBootstrap = $this->view->formatFormBootstrap2();
        $site = $this->view->site;

        $user = isset( $input['user'] ) && $input['user'] ? $input['user'] : null;

        if ( ! $user ) {
            return '&nbsp;';
        }

        $value = '';
        $givenBadgeIds = $user->getGivenResponseBadgeIds( $response );
        if ( $givenBadgeIds ) {
            $value = $givenBadgeIds[0];
        }

        $formItems = array();
        $items = array(
            '' => array( 'text' => 'None', 'value' => '' )
        );

        $badges = $site->getBadges();
        foreach ( $badges as $badge ) {
            $items[$badge->getId()] = array( 'text' => $badge->getName(), 'value' => $badge->getId() );
        }

        $formItems['badgeId'] = $formatFormBootstrap->getRadios(
            array(
                'name' => 'badgeId',
                'value' => $value,
                'defaultValue' => '',
                'items' => $items,
            ),
            array(
                'text' => '',
            )
        );

        return '
            <form action="'.$site->getUrl( 'postBadgeEditConfirm' ).'" method="post" class="dynamic-form">
                '.$formatFormBootstrap->getList( $formItems ).'
                '.$formatFormBootstrap->getHiddenSimple( 'responseId', $response->getId() ).'
                '.$formatFormBootstrap->getHiddenSimple( 'userId', $user->getId() ).'
            </form>
        ';
    }

    /**
     * Get data for 'mentorId' column
     *
     * @param BeMaverick_User_Mentor $mentor
     * @param hash $input
     * @return string
     */
    protected function _mentorId( $mentor, $input )
    {
        return $mentor->getId();
    }

    /**
     * Get data for 'mentorProfileImage' column
     *
     * @param BeMaverick_User_Mentor $mentor
     * @param hash $input
     * @return string
     */
    protected function _mentorProfileImage( $mentor, $input )
    {
        $profileImage = $mentor->getProfileImage();

        if ( ! $profileImage ) {
            return '';
        }

        return '<img src="' . $profileImage->getUrl( 100, 100 ) . '" width="100" height="100">';
    }

    /**
     * Get data for 'mentorFirstName' column
     *
     * @param BeMaverick_User_Mentor $mentor
     * @param hash $input
     * @return string
     */
    protected function _mentorFirstName( $mentor, $input )
    {
        return $mentor->getFirstName();
    }

    /**
     * Get data for 'mentorLastName' column
     *
     * @param BeMaverick_User_Mentor $mentor
     * @param hash $input
     * @return string
     */
    protected function _mentorLastName( $mentor, $input )
    {
        return $mentor->getLastName();
    }

//    /**
//     * Get data for 'mentorShortDescription' column
//     *
//     * @param BeMaverick_User_Mentor $mentor
//     * @param hash $input
//     * @return string
//     */
//    protected function _mentorShortDescription( $mentor, $input )
//    {
//        return $mentor->getShortDescription();
//    }

    /**
     * Get data for 'mentorAction' column
     *
     * @param BeMaverick_User_Mentor $mentor
     * @param hash $input
     * @return string
     */
    protected function _mentorAction( $mentor, $input )
    {

        $params = array(
            'mentorId' => $mentor->getId(),
        );

        $links = array(
            'edit' => array(
                'title' => 'Edit',
                'link' => $this->view->site->getUrl( 'mentorEdit', $params ),
            ),
        );

        return $this->view->linkList( $links );
    }

    /**
     * Get data for 'contentId' column
     *
     * @param BeMaverick_Content $content
     * @param hash $input
     * @return string
     */
    protected function _contentId( $content, $input )
    {
        return $content->getId();
    }

    /**
     * Get data for 'contentVideoThumbnail' column
     *
     * @param BeMaverick_Content $content
     * @param hash $input
     * @return string
     */
    protected function _contentVideoThumbnail( $content, $input )
    {

        $contentType = $content->getContentType();
        $video = $content->getVideo();
        $image = $content->getImage();
        $html='';

        if ( $contentType == BeMaverick_Content::CONTENT_TYPE_VIDEO && $video ) {

            $html = '<img src="' . $video->getThumbnailUrl() . '" width="60" height="108" />';

        } else if ( $contentType == BeMaverick_Content::CONTENT_TYPE_IMAGE && $image ) {
            $html = '<img src="' . $image->getUrl( 60, 108 ) . '" width="60" height="108" />';
        }

        return $html;
    }

    /**
     * Get data for 'contentTitle' column
     *
     * @param BeMaverick_Content $content
     * @param hash $input
     * @return string
     */
    protected function _contentTitle( $content, $input )
    {
        return $content->getTitle();
    }

    /**
     * Get data for 'contentUserUsername' column
     *
     * @param BeMaverick_Content $content
     * @param hash $input
     * @return string
     */
    protected function _contentUsername( $content, $input )
    {
        $user = $content->getUser();

        return $user->getUsername();
    }

    /**
     * Get data for 'contentType' column
     *
     * @param BeMaverick_Content $content
     * @param hash $input
     * @return string
     */
    protected function _contentType( $content, $input )
    {
        return ucfirst( $content->getContentType() );
    }

    /**
     * Get data for 'contentStatus' column
     *
     * @param BeMaverick_Content $content
     * @param hash $input
     * @return string
     */
    protected function _contentStatus( $content, $input )
    {
        $status = $content->getStatus();

        if ( $status == 'active' ) {
            $cssClass = 'label-primary';
        } else if ( $status == 'inactive' || $status == 'deleted' ) {
            $cssClass = 'label-danger';
        } else {
            $cssClass = 'label-default';
        }

        return '<span class="label ' . $cssClass . '">'. ucfirst( $status ) . '</span>';
    }

    /**
     * Get data for 'contenteAction' column
     *
     * @param BeMaverick_Content $content
     * @param hash $input
     * @return string
     */
    protected function _contentAction( $content, $input )
    {

        $params = array(
            'contentId' => $content->getId(),
        );

        $links = array(
            'edit' => array(
                'title' => 'Edit',
                'link' => $this->view->site->getUrl( 'contentEdit', $params ),
            ),
        );

        return $this->view->linkList( $links );
    }


    /**
     * Get data for 'streamId' column
     *
     * @param BeMaverick_Stream $stream
     * @param hash $input
     * @return string
     */
    protected function _streamId( $stream, $input )
    {
        return $stream->getId();
    }

    /**
     * Get data for 'streamIdWithHidenInput' column
     *
     * @param BeMaverick_Response $stream
     * @param hash $input
     * @return string
     */
    protected function _streamIdWithHiddenInput( $stream, $input )
    {
        $html = "";
        $html .= $stream->getId();
        $html .= '<input type="hidden" name="streamIds[]" value="' . $stream->getId() . '">';

        return $html;
    }

    /**
     * Get data for 'streamLabel' column
     *
     * @param BeMaverick_Stream $stream
     * @param hash $input
     * @return string
     */
    protected function _streamLabel( $stream, $input )
    {
        return $stream->getLabel();
    }

    /**
     * Get data for 'streamStatus' column
     *
     * @param BeMaverick_Stream $stream
     * @param hash $input
     * @return string
     */
    protected function _streamStatus( $stream, $input )
    {
        $status = $stream->getStatus();

        if ( $status == 'active' ) {
            $cssClass = 'label-primary';
        } else if ( $status == 'hidden' ) {
            $cssClass = 'label-danger';
        } else {
            $cssClass = 'label-default';
        }

        return '<span class="label ' . $cssClass . '">'. ucfirst( $status ) . '</span>';
    }

    /**
     * Get data for 'streamType' column
     *
     * @param BeMaverick_Stream $stream
     * @param hash $input
     * @return string
     */
    protected function _streamType( $stream, $input )
    {

        return $stream->getStreamTypePretty();
    }

    /**
     * Get data for 'streamModelType' column
     *
     * @param BeMaverick_Stream $stream
     * @param hash $input
     * @return string
     */
    protected function _streamModelType( $stream, $input )
    {
        return $stream->getModelType();
    }

    /**
     * Get data for 'streamAction' column
     *
     * @param BeMaverick_Stream $stream
     * @param hash $input
     * @return string
     */
    protected function _streamAction( $stream, $input )
    {
        $streamId = $stream->getId();
        $streamType = $stream->getStreamType();
        $definition = $stream->getDefinition();
        $featuredType = $definition['featuredType'] ?? 'stream-'.$streamId;
        // print("<pre>".print_r($definition,true)."</pre>");
        
        $links = array();

        // return $streamType;

        switch($streamType) {
            case 'FEATURED_RESPONSES':
                $params = array(
                    'featuredType' => $featuredType,
                    'streamId' => $streamId,
                );
                $links['edit'] = array(
                    'title' => '<span class="glyphicon glyphicon-pencil"></span>&nbsp; Edit',
                    'link' => $this->view->site->getUrl( 'featuredResponsesEdit', $params ),
                );
                break;
            case 'FEATURED_CHALLENGES':
                $params = array(
                    'featuredType' => $featuredType,
                    'streamId' => $streamId,
                );
                $links['edit'] = array(
                    'title' => '<span class="glyphicon glyphicon-pencil"></span>&nbsp; Edit',
                    'link' => $this->view->site->getUrl( 'featuredChallengesEdit', $params ),
                );
                break;
            case 'AD_BLOCK':
                $params = array(
                    'streamId' => $streamId,
                );
                $links['edit'] = array(
                    'title' => '<span class="glyphicon glyphicon-pencil"></span>&nbsp; Edit',
                    'link' => $this->view->site->getUrl( 'streamsAdBlockEdit', $params ),
                );
                break;
            case 'LATEST_RESPONSES':
                $params = array(
                    'streamId' => $streamId,
                );
                $links['edit'] = array(
                    'title' => '<span class="glyphicon glyphicon-pencil"></span>&nbsp; Edit',
                    'link' => $this->view->site->getUrl( 'streamsLatestResponsesEdit', $params ),
                );
                break;
            default:
            break;
        }

        return $this->view->linkList( $links );
    }


    /**
     * Get data for 'badgeId' column
     *
     * @param BeMaverick_Stream $badge
     * @param hash $input
     * @return string
     */
    protected function _badgeId( $badge, $input )
    {
        $html = '';
        $html .= '<input type="hidden" name="badgeIds[]" value="' . $badge->getId() . '">';
        $html .= $badge->getId();

        return $html;
    }

    /**
     * Get data for 'badgeName' column
     *
     * @param BeMaverick_Stream $badge
     * @param hash $input
     * @return string
     */
    protected function _badgeName( $badge, $input )
    {
        return $badge->getName();
    }

    /**
     * Get data for 'badgeColor' column
     *
     * @param BeMaverick_Stream $badge
     * @param hash $input
     * @return string
     */
    protected function _badgeColor( $badge, $input )
    {
        $color = $badge->getColor();
        $style = "background-color: $color; padding: 10px 20px;";

        $label = '<span class="label" style="'.$style.'">'. strtoupper( $color ) . '</span>';

        return $label;
    }

    /**
     * Get data for 'badgeStatus' column
     *
     * @param BeMaverick_Content $badge
     * @param hash $input
     * @return string
     */
    protected function _badgeStatus( $badge, $input )
    {
        $status = $badge->getStatus();

        if ( $status == 'active' ) {
            $cssClass = 'label-primary';
        } else if ( $status == 'inactive' || $status == 'deleted' ) {
            $cssClass = 'label-danger';
        } else {
            $cssClass = 'label-default';
        }

        return '<span class="label ' . $cssClass . '">'. ucfirst( $status ) . '</span>';
    }

    /**
     * Get data for 'hideFromStreams' column
     *
     * @param BeMaverick_Content $response
     * @param hash $input
     * @return string
     */
    protected function _responseHideFromStreams( $response, $input )
    {
        $hidden = $response ? $response->isHideFromStreams() : false;

        if ( $hidden ) {
            $cssClass = 'label-danger';
            $text = 'hidden';
        } else {
            $cssClass = 'label-primary';
            $text = 'visible';
        } 

        return '<span class="label ' . $cssClass . '">'. $text . '</span>';
    }



    /**
     * Get data for 'badgePrimaryImage' column
     *
     * @param BeMaverick_Stream $badge
     * @param hash $input
     * @return string
     */
    protected function _badgePrimaryImage( $badge, $input )
    {
        $url = $badge->getPrimaryImageUrl();
        $image = "<img style='max-height: 50px;' src='$url' />";
        
        return $image;
    }
    /**
     * Get data for 'badgeSecondaryImage' column
     *
     * @param BeMaverick_Stream $badge
     * @param hash $input
     * @return string
     */
    protected function _badgeSecondaryImage( $badge, $input )
    {
        $url = $badge->getSecondaryImageUrl();
        $image = "<img style='max-height: 30px;' src='$url' />";
        
        return $image;
    }


    protected function _upDown() {
        $html = '<a href="#" class="up"><span class="glyphicon glyphicon-chevron-up"></span></a><br/>
            <a href="#" class="down"><span class="glyphicon glyphicon-chevron-down"></span></a>';
        return $html;
    }

}
