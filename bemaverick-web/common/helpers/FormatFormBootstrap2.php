<?php
require_once( SLY_ROOT_DIR . '/lib/Sly/View/Helper/FormatFormBootstrap2.php' );

class BeMaverick_View_Helper_FormatFormBootstrap2 extends Sly_View_Helper_FormatFormBootstrap2
{

    /**
     * Get the default input attributes
     *
     * @return array
     */
    public function getDefaultInputAttributes()
    {
        return array( 'class' => 'form-control' );
    }

    /**
     * Get the default buttons options
     *
     * @return array
     */
    public function getDefaultButtonsOptions()
    {
        return array( 'preContent' => '<div class="buttons-spacer"></div><div class="buttons-wrap">', 'postContent' => '</div>' );
    }

    /**
     * Get the textbox
     *
     * @param array $input
     * @param array $label
     * @param array $options
     * @return string
     */
    public function getTextbox( $input = array(), $label = array(), $options = array() )
    {
        $defaultInputAttributes = $this->getDefaultInputAttributes();
        $attributes = isset( $input['attributes'] ) ? $input['attributes'] : array();
        $input['attributes'] = array_merge( $defaultInputAttributes, $attributes );
        return parent::getTextbox( $input, $label, $options );
    }

    /**
     * Get the select
     *
     * @param array $input
     * @param array $label
     * @param array $options
     * @return string
     */
    public function getSelect( $input = array(), $label = array(), $options = array() )
    {
        $defaultInputAttributes = $this->getDefaultInputAttributes();
        $attributes = isset( $input['attributes'] ) ? $input['attributes'] : array();
        $input['attributes'] = array_merge( $defaultInputAttributes, $attributes );
        return parent::getSelect( $input, $label, $options );
    }

    /**
     * Get the email address
     *
     * @param string $value
     * @param string $defaultValue
     * @param array|null $mergeInputSettings
     * @param array|null $mergeLabelSettings
     * @param array|null $mergeOptions
     * @return string
     */
    public function getEmailAddress( $value, $defaultValue, $mergeInputSettings = null, $mergeLabelSettings = null, $mergeOptions = null )
    {
        $inputSettings = array(
            'value' => $value,
            'defaultValue' => $defaultValue,
            'name' => 'emailAddress',
            'type' => 'email',
            'attributes' => $this->getDefaultInputAttributes()
        );

        $labelSettings = array(
            'text' => 'Email Address',
        );

        $options = array(
            'attributes' => array(
                'class' => 'form-item--small'
            )
        );

        if ( $mergeInputSettings ) {
            $inputSettings = array_merge( $inputSettings, $mergeInputSettings );
        }
        if ( $mergeLabelSettings ) {
            $labelSettings = array_merge( $labelSettings, $mergeLabelSettings );
        }
        if ( $mergeOptions ) {
            $options = array_merge( $options, $mergeOptions );
        }

        return $this->getTextbox( $inputSettings, $labelSettings, $options );
    }

    /**
     * Get the parent email address
     *
     * @param string $value
     * @param string $defaultValue
     * @return string
     */
    public function getParentEmailAddress( $value, $defaultValue )
    {
        $inputSettings = array(
            'value' => $value,
            'defaultValue' => $defaultValue,
            'name' => 'parentEmailAddress',
            'type' => 'email',
            'attributes' => $this->getDefaultInputAttributes()
        );

        $labelSettings = array(
            'text' => 'Parent Email Address',
        );

        $options = array(
            'attributes' => array(
                'class' => 'form-item--small'
            )
        );

        return $this->getTextbox( $inputSettings, $labelSettings, $options );
    }

    /**
     * Get the username
     *
     * @param string $value
     * @param string $defaultValue
     * @param array|null $mergeInputSettings
     * @param array|null $mergeLabelSettings
     * @param array|null $mergeOptions
     * @return string
     */
    public function getUsername( $value, $defaultValue, $mergeInputSettings = null, $mergeLabelSettings = null, $mergeOptions = null )
    {
        $inputSettings = array(
            'value' => $value,
            'defaultValue' => $defaultValue,
            'name' => 'username',
            'isRequired' => false,
            'attributes' => $this->getDefaultInputAttributes()
        );
        $labelSettings = array(
            'text' => 'Username',
        );
        $options = array(
            'attributes' => array(
                'class' => 'form-item--small'
            )
        );
        if ( $mergeInputSettings ) {
            $inputSettings = array_merge( $inputSettings, $mergeInputSettings );
        }
        if ( $mergeLabelSettings ) {
            $labelSettings = array_merge( $labelSettings, $mergeLabelSettings );
        }
        if ( $mergeOptions ) {
            $options = array_merge( $options, $mergeOptions );
        }
        return $this->getTextbox( $inputSettings, $labelSettings, $options );
    }
    /**
     * Get the password
     *
     * @param string $value
     * @param string $defaultValue
     * @param array|null $mergeInputSettings
     * @param array|null $mergeLabelSettings
     * @param array|null $mergeOptions
     * @return string
     */
    public function getPassword( $value, $defaultValue = '', $mergeInputSettings = null, $mergeLabelSettings = null, $mergeOptions = null )
    {
        $inputSettings = array(
            'value' => $value,
            'defaultValue' => $defaultValue,
            'name' => 'password',
            'type' => 'password',
            'isRequired' => true,
            'attributes' => $this->getDefaultInputAttributes()
        );
        $labelSettings = array(
            'text' => 'Password',
        );
        $options = array(
            'attributes' => array(
                'class' => 'form-item--small'
            )
        );
        if ( $mergeInputSettings ) {
            $inputSettings = array_merge( $inputSettings, $mergeInputSettings );
        }
        if ( $mergeLabelSettings ) {
            $labelSettings = array_merge( $labelSettings, $mergeLabelSettings );
        }
        if ( $mergeOptions ) {
            $options = array_merge( $options, $mergeOptions );
        }
        return $this->getTextbox( $inputSettings, $labelSettings, $options );
    }

    /**
     * Get the birthdate
     *
     * @param string $value
     * @param string $defaultValue
     * @return string
     */
    public function getBirthdate( $value, $defaultValue )
    {
        $inputSettings = array(
            'value' => $value,
            'defaultValue' => $defaultValue,
            'name' => 'birthdate',
        );

        $labelSettings = array(
            'text' => 'Date of Birth',
        );

        $options = array(
            'attributes' => array(
                'class' => 'form-item--small'
            ),
            'placeholder' => 'YYYY-MM-DD',
        );

        return $this->getTextbox( $inputSettings, $labelSettings, $options );
    }


    /**
     * Get the query form item
     *
     * @param string $value
     * @param string $defaultValue
     * @return string
     */
    public function getQuery( $value, $defaultValue, $text = 'Query' )
    {
        $inputSettings = array(
            'value' => $value,
            'defaultValue' => $defaultValue,
            'name' => 'query',
            'attributes' => $this->getDefaultInputAttributes()
        );

        $labelSettings = array(
            'text' => $text,
        );

        return $this->getTextbox( $inputSettings, $labelSettings );
    }

    /**
     * Get the user type
     *
     * @param string $value
     * @param string $defaultValue
     * @return string
     */
    public function getUserType( $value, $defaultValue )
    {
        $items = array(
            '' => array( 'value' => '', 'text' => '' ),
            'kid' => array( 'value' => 'kid', 'text' => 'Kid' ),
            'mentor' => array( 'value' => 'mentor', 'text' => 'Catalyst' ),
            'parent' => array( 'value' => 'parent', 'text' => 'Parent' ),
        );

        $inputSettings = array(
            'value' => $value,
            'defaultValue' => $defaultValue,
            'name' => 'userType',
            'items' => $items,
        );

        $labelSettings = array(
            'text' => 'User Type',
        );

        $options = array(
            'attributes' => array(
                'class' => 'form-item--small'
            )
        );

        return $this->getSelect( $inputSettings, $labelSettings, $options );
    }

    /**
     * Get the user type (with no blank or parent option/value)
     *
     * @param string $value
     * @param string $defaultValue
     * @return string
     */
    public function getMaverickType( $value, $defaultValue )
    {
        $items = array(
            'kid' => array( 'value' => 'kid', 'text' => 'Kid' ),
            'mentor' => array( 'value' => 'mentor', 'text' => 'Catalyst' ),
        );

        $inputSettings = array(
            'value' => $value,
            'defaultValue' => $defaultValue,
            'name' => 'userType',
            'items' => $items,
        );

        $labelSettings = array(
            'text' => 'User Type',
        );

        $options = array(
            'attributes' => array(
                'class' => 'form-item--small'
            )
        );

        return $this->getSelect( $inputSettings, $labelSettings, $options );
    }

    /**
     * Get the start age
     *
     * @param string $value
     * @param string $defaultValue
     * @return string
     */
    public function getStartAge( $value, $defaultValue = '' )
    {
        $inputSettings = array(
            'value' => $value,
            'defaultValue' => $defaultValue,
            'name' => 'startAge',
        );

        $labelSettings = array(
            'text' => 'Start Age',
        );

        return $this->getTextbox( $inputSettings, $labelSettings );
    }

    /**
     * Get the end age
     *
     * @param string $value
     * @param string $defaultValue
     * @return string
     */
    public function getEndAge( $value, $defaultValue = '' )
    {
        $inputSettings = array(
            'value' => $value,
            'defaultValue' => $defaultValue,
            'name' => 'endAge',
        );

        $labelSettings = array(
            'text' => 'End Age',
        );

        return $this->getTextbox( $inputSettings, $labelSettings );
    }

    /**
     * Get the start registered date
     *
     * @param string $value
     * @param string $defaultValue
     * @return string
     */
    public function getStartRegisteredDate( $value, $defaultValue = '' )
    {
        $inputSettings = array(
            'value' => $value,
            'defaultValue' => $defaultValue,
            'name' => 'startRegisteredDate',
        );

        $labelSettings = array(
            'text' => 'Start Reg Date',
        );

        $options = array(
            'placeholder' => 'YYYY-MM-DD',
        );

        return $this->getTextbox( $inputSettings, $labelSettings, $options );
    }

    /**
     * Get the end registered date
     *
     * @param string $value
     * @param string $defaultValue
     * @return string
     */
    public function getEndRegisteredDate( $value, $defaultValue = '' )
    {
        $inputSettings = array(
            'value' => $value,
            'defaultValue' => $defaultValue,
            'name' => 'endRegisteredDate',
        );

        $labelSettings = array(
            'text' => 'End Reg Date',
        );

        $options = array(
            'placeholder' => 'YYYY-MM-DD',
        );

        return $this->getTextbox( $inputSettings, $labelSettings, $options );
    }

    /**
     * Get the challenge status
     *
     * @param string $value
     * @param string $defaultValue
     * @return string
     */
    public function getChallengeStatus( $value, $defaultValue )
    {
        $items = array(
            '' => array( 'value' => '', 'text' => '' ),
            'draft' => array( 'value' => 'draft', 'text' => 'Draft' ),
            'published' => array( 'value' => 'published', 'text' => 'Published' ),
            'hidden' => array( 'value' => 'hidden', 'text' => 'Hidden' ),
            'deleted' => array( 'value' => 'deleted', 'text' => 'Deleted' ),
        );

        $inputSettings = array(
            'value' => $value,
            'defaultValue' => $defaultValue,
            'name' => 'challengeStatus',
            'items' => $items,
        );

        $labelSettings = array(
            'text' => 'Status',
        );

        $options = array(
            'attributes' => array(
                'class' => 'form-item--small'
            )
        );

        return $this->getSelect( $inputSettings, $labelSettings, $options );
    }

    /**
     * Get the challenge
     *
     * @param string $value
     * @param string $defaultValue
     * @return string
     */
    public function getChallenge( $value, $defaultValue )
    {
        $site = $this->view->site;

        $items = array(
            '' => array( 'value' => '', 'text' => '' ),
        );

        $challenges = $site->getChallenges();
        foreach ( $challenges as $challenge ) {
            $items[$challenge->getId()] = array( 'value' => $challenge->getId(), 'text' => $challenge->getTitle() );
        }

        $inputSettings = array(
            'value' => $value,
            'defaultValue' => $defaultValue,
            'name' => 'challengeId',
            'items' => $items,
        );

        $labelSettings = array(
            'text' => 'Challenge',
        );

        $options = array(
            'attributes' => array(
                'class' => 'form-item--small'
            )
        );

        return $this->getSelect( $inputSettings, $labelSettings, $options );
    }

    /**
     * Get the challenge
     *
     * @param string $value
     * @param string $defaultValue
     * @param string $size
     * @param string $type
     * @return string
     */
    public function getChallengeAutocomplete( $value, $defaultValue = null, $size = "", $type = 'search', $label = null )
    {
        $site = $this->view->site;

        $currentChallenge = $value ? $site->getChallenge( $value ) : null;
        $defaultChallenge = $defaultValue ? $site->getChallenge( $defaultValue ) : null;

        $inputSettings = array(
            'value' => $currentChallenge ? $currentChallenge->getTitle() : '',
            'defaultValue' => $defaultChallenge ? $defaultChallenge->getTitle() : '',
            'name' => 'challengeName',
            'postContent' => $this->getHiddenSimple( 'challengeId', ( $value ? $value : $defaultValue ) ),
            'attributes' => array(
                'data-auto-complete-url' => '/autocomplete/challenges',
                'data-auto-complete-action' => $type
            )
        );

        $labelSettings = array(
            'text' => $label ?? 'Challenge Title',
        );

        $sizeClass = $size ? " form-item--".$size : "";
        $options = array(
            'attributes' => array(
                'class' => 'auto-complete'.$sizeClass
            )
        );

        return $this->getTextbox( $inputSettings, $labelSettings, $options );
    }

    /**
     * Get the challengeId
     *
     * @param string $value
     * @param string $defaultValue
     * @param string $size
     * @return string
     */
    public function getChallengeId( $value, $defaultValue = null )
    {
        $inputSettings = array(
            'value' => $value,
            'defaultValue' => $defaultValue,
            'name' => 'challengeId',
        );

        $labelSettings = array(
            'text' => 'Challenge ID',
        );

        $options = array(
            'attributes' => array(
                'class' => 'form-item--medium'
            )
        );

        return $this->getTextbox( $inputSettings, $labelSettings, $options );
    }

    /**
     * Get the challenge title
     *
     * @param string $value
     * @param string $defaultValue
     * @return string
     */
    public function getChallengeTitle( $value, $defaultValue )
    {
        $inputSettings = array(
            'value' => $value,
            'defaultValue' => $defaultValue,
            'name' => 'challengeTitle',
        );

        $labelSettings = array(
            'text' => 'Title',
        );

        $options = array(
            'attributes' => array(
                'class' => 'form-item--medium'
            )
        );

        return $this->getTextbox( $inputSettings, $labelSettings, $options );
    }


    /**
     * Get the challenge type
     *
     * @param string $value
     * @param string $defaultValue
     * @param array|null $mergeInputSettings
     * @param array|null $mergeLabelSettings
     * @param array|null $mergeOptions
     * @return string
     */
    public function getChallengeType( $value, $defaultValue='', $mergeInputSettings = null, $mergeLabelSettings = null, $mergeOptions = null )
    {
        $items = array(
            '' => array( 'value' => '', 'text' => '' ),
            'video' => array( 'value' => 'video', 'text' => 'Video' ),
            'image' => array( 'value' => 'image', 'text' => 'Image' ),
        );

        $inputSettings = array(
            'value' => $value,
            'defaultValue' => $defaultValue,
            'name' => 'challengeType',
            'items' => $items,
        );

        $labelSettings = array(
            'text' => 'Type',
        );

        $options = array(
            'attributes' => array(
                'class' => 'form-item--small'
            )
        );

        if ( $mergeInputSettings ) {
            $inputSettings = array_merge( $inputSettings, $mergeInputSettings );
        }

        if ( $mergeLabelSettings ) {
            $labelSettings = array_merge( $labelSettings, $mergeLabelSettings );
        }

        if ( $mergeOptions ) {
            $options = array_merge( $options, $mergeOptions );
        }

        return $this->getSelect( $inputSettings, $labelSettings, $options );
    }

    /**
     * Get the challenge description
     *
     * @param string $value
     * @param string $defaultValue
     * @return string
     */
    public function getChallengeDescription( $value, $defaultValue )
    {
        $inputSettings = array(
            'value' => $value,
            'defaultValue' => $defaultValue,
            'name' => 'challengeDescription',
        );

        $labelSettings = array(
            'text' => 'Description',
        );

        $options = array(
            'attributes' => array(
                'class' => 'form-item--medium'
            )
        );

        return $this->getTextarea( $inputSettings, $labelSettings, $options );
    }

    /**
     * Get the challenge description
     *
     * @param string $value
     * @param string $defaultValue
     * @return string
     */
    public function getChallengeLinkUrl( $value, $defaultValue )
    {
        $inputSettings = array(
            'value' => $value,
            'defaultValue' => $defaultValue,
            'name' => 'challengeLinkUrl',
        );

        $labelSettings = array(
            'text' => 'Link Url',
        );

        $options = array(
            'attributes' => array(
                'class' => 'form-item--medium'
            )
        );

        return $this->getTextarea( $inputSettings, $labelSettings, $options );
    }

    /**
     * Get the challenge tags
     *
     * @param string $value
     * @param string $defaultValue
     * @param array|null $mergeInputSettings
     * @param array|null $mergeLabelSettings
     * @param array|null $mergeOptions
     * @return string
     */
    public function getTagNames( $value, $defaultValue, $mergeInputSettings = null, $mergeLabelSettings = null, $mergeOptions = null )
    {
        $inputSettings = array(
            'value' => $value,
            'defaultValue' => $defaultValue,
            'name' => 'tagNames',
        );

        $labelSettings = array(
            'text' => 'Tags',
        );

        $options = array(
            'attributes' => array(
                'class' => 'form-item--medium'
            )
        );

        if ( $mergeInputSettings ) {
            $inputSettings = array_merge( $inputSettings, $mergeInputSettings );
        }

        if ( $mergeLabelSettings ) {
            $labelSettings = array_merge( $labelSettings, $mergeLabelSettings );
        }

        if ( $mergeOptions ) {
            $options = array_merge( $options, $mergeOptions );
        }

        return $this->getTextbox( $inputSettings, $labelSettings, $options );
    }

    /**
     * Get the content status
     *
     * @param string $value
     * @param string $defaultValue
     * @return string
     */
    public function getContentStatus( $value, $defaultValue, $class = null )
    {
        $items = array(
            '' => array( 'value' => '', 'text' => '' ),
            'draft' => array( 'value' => 'draft', 'text' => 'Draft' ),
            'active' => array( 'value' => 'active', 'text' => 'Active' ),
            'inactive' => array( 'value' => 'inactive', 'text' => 'Inactive' ),
            'deleted' => array( 'value' => 'deleted', 'text' => 'Deleted' ),
        );

        $inputSettings = array(
            'value' => $value,
            'defaultValue' => $defaultValue,
            'name' => 'contentStatus',
            'items' => $items,
        );

        $labelSettings = array(
            'text' => 'Status',
        );

        $options = array(
            'attributes' => array(
                'class' => $class ?? 'form-item--small'
            )
        );

        return $this->getSelect( $inputSettings, $labelSettings, $options );
    }

    /**
     * Get the stream status
     *
     * @param string $value
     * @param string $defaultValue
     * @return string
     */
    public function getStreamStatus( $value, $defaultValue )
    {
        $items = array(
            '' => array( 'value' => '', 'text' => '' ),
            'active' => array( 'value' => 'active', 'text' => 'Active' ),
            'inactive' => array( 'value' => 'inactive', 'text' => 'Inactive' ),
            // 'deleted' => array( 'value' => 'deleted', 'text' => 'Deleted' ),
        );

        $inputSettings = array(
            'value' => $value,
            'defaultValue' => $defaultValue,
            'name' => 'contentStatus',
            'items' => $items,
        );

        $labelSettings = array(
            'text' => 'Status',
        );

        $options = array(
            'attributes' => array(
                'class' => 'form-item'
            )
        );

        return $this->getSelect( $inputSettings, $labelSettings, $options );
    }

    /**
     * Get the content title
     *
     * @param string $value
     * @param string $defaultValue
     * @return string
     */
    public function getContentTitle( $value, $defaultValue )
    {
        $inputSettings = array(
            'value' => $value,
            'defaultValue' => $defaultValue,
            'name' => 'contentTitle',
        );

        $labelSettings = array(
            'text' => 'Title',
        );

        $options = array(
            'attributes' => array(
                'class' => 'form-item--medium'
            )
        );

        return $this->getTextbox( $inputSettings, $labelSettings, $options );
    }

    /**
     * Get the content description
     *
     * @param string $value
     * @param string $defaultValue
     * @return string
     */
    public function getContentDescription( $value, $defaultValue )
    {
        $inputSettings = array(
            'value' => $value,
            'defaultValue' => $defaultValue,
            'name' => 'contentDescription',
        );

        $labelSettings = array(
            'text' => 'Description',
        );

        $options = array(
            'attributes' => array(
                'class' => 'form-item--medium'
            )
        );

        return $this->getTextarea( $inputSettings, $labelSettings, $options );
    }

    /**
     * Get the content type
     *
     * @param string $value
     * @param string $defaultValue
     * @return string
     */
    public function getContentType( $value, $defaultValue )
    {
        $items = array(
            '' => array( 'value' => '', 'text' => '' ),
            'video' => array( 'value' => 'video', 'text' => 'Video' ),
            'image' => array( 'value' => 'image', 'text' => 'Image' ),
        );

        $inputSettings = array(
            'value' => $value,
            'defaultValue' => $defaultValue,
            'name' => 'contentType',
            'items' => $items,
        );

        $labelSettings = array(
            'text' => 'Type',
        );

        $options = array(
            'attributes' => array(
                'class' => 'form-item--small'
            )
        );
        return $this->getSelect( $inputSettings, $labelSettings, $options );
    }

    /**
     * Get the sort order
     *
     * @param string $value
     * @param string $defaultValue
     * @return string
     */
    public function getSortOrder( $value, $defaultValue )
    {
        $inputSettings = array(
            'value' => $value,
            'defaultValue' => $defaultValue,
            'name' => 'sortOrder',
        );


        $labelSettings = array(
            'text' => 'Sort Order',
        );

        $options = array(
            'attributes' => array(
                'class' => 'form-item--small'
            )
        );

        return $this->getTextbox( $inputSettings, $labelSettings, $options );
    }

    /**
     * Get the video upload
     *
     * @param array|null $mergeInputSettings
     * @param array|null $mergeLabelSettings
     * @param array|null $mergeOptions
     * @return string
     */
    public function getVideoFileUpload( $mergeInputSettings = null, $mergeLabelSettings = null, $mergeOptions = null )
    {
        $inputSettings = array(
            'name' => 'video',
        );

        $labelSettings = array(
            'text' => 'Video',
        );

        $options = array();

        if ( $mergeInputSettings ) {
            $inputSettings = array_merge( $inputSettings, $mergeInputSettings );
        }

        if ( $mergeLabelSettings ) {
            $labelSettings = array_merge( $labelSettings, $mergeLabelSettings );
        }

        if ( $mergeOptions ) {
            $options = array_merge( $options, $mergeOptions );
        }

        return $this->getFileUpload( $inputSettings, $labelSettings, $options );
    }

    /**
     * Get the mentor
     *
     * @param string $value
     * @param string $defaultValue
     * @return string
     */
    public function getMentor( $value, $defaultValue )
    {
        $site = $this->view->site;

        $options = array(
            '' => array( 'value' => '', 'text' => '' ),
        );

        $sortBy = array(
            'sort' => 'mentorName',
            'sortOrder' => 'asc',
        );

        $mentors = $site->getMentors( null, $sortBy );
        foreach ( $mentors as $mentor ) {
            if ( $mentor ) {
                $mentorId = $mentor->getId();
                $mentorName = $mentor->getName();
                $options[$mentorId] = array( 'value' => $mentorId, 'text' => $mentorName );
            }
        }

        $inputSettings = array(
            'value' => $value,
            'defaultValue' => $defaultValue,
            'name' => 'mentorId',
            'items' => $options,
        );

        $labelSettings = array(
            'text' => 'Catalyst',
        );

        $options = array(
            'attributes' => array(
                'class' => 'form-item--medium'
            )
        );

        return $this->getSelect( $inputSettings, $labelSettings, $options );
    }

    /**
     * Get the first name
     *
     * @param string $value
     * @param string $defaultValue
     * @param array|null $mergeInputSettings
     * @param array|null $mergeLabelSettings
     * @param array|null $mergeOptions
     * @return string
     */
    public function getFirstName( $value, $defaultValue = '', $mergeInputSettings = null, $mergeLabelSettings = null, $mergeOptions = null )
    {
        $inputSettings = array(
            'value' => $value,
            'defaultValue' => $defaultValue,
            'name' => 'firstName',
        );

        $labelSettings = array(
            'text' => 'First Name',
        );

        $options = array(
            'attributes' => array(
                'class' => 'form-item--small'
            )
        );

        if ( $mergeInputSettings ) {
            $inputSettings = array_merge( $inputSettings, $mergeInputSettings );
        }
        if ( $mergeLabelSettings ) {
            $labelSettings = array_merge( $labelSettings, $mergeLabelSettings );
        }
        if ( $mergeOptions ) {
            $options = array_merge( $options, $mergeOptions );
        }

        return $this->getTextbox( $inputSettings, $labelSettings, $options );
    }

    /**
     * Get the last name
     *
     * @param string $value
     * @param string $defaultValue
     * @param array|null $mergeInputSettings
     * @param array|null $mergeLabelSettings
     * @param array|null $mergeOptions
     * @return string
     */
    public function getLastName( $value, $defaultValue = '', $mergeInputSettings = null, $mergeLabelSettings = null, $mergeOptions = null )
    {
        $inputSettings = array(
            'value' => $value,
            'defaultValue' => $defaultValue,
            'name' => 'lastName',
        );

        $labelSettings = array(
            'text' => 'Last Name',
        );

        $options = array(
            'attributes' => array(
                'class' => 'form-item--small'
            )
        );

        if ( $mergeInputSettings ) {
            $inputSettings = array_merge( $inputSettings, $mergeInputSettings );
        }
        if ( $mergeLabelSettings ) {
            $labelSettings = array_merge( $labelSettings, $mergeLabelSettings );
        }
        if ( $mergeOptions ) {
            $options = array_merge( $options, $mergeOptions );
        }

        return $this->getTextbox( $inputSettings, $labelSettings, $options );
    }

    /**
     * Get the address
     *
     * @param string $value
     * @param string $defaultValue
     * @param array|null $mergeInputSettings
     * @param array|null $mergeLabelSettings
     * @return string
     */
    public function getAddress( $value, $defaultValue = '', $mergeInputSettings = null, $mergeLabelSettings = null )
    {
        $inputSettings = array(
            'value' => $value,
            'defaultValue' => $defaultValue,
            'name' => 'address',
        );

        $labelSettings = array(
            'text' => 'Address',
        );

        if ( $mergeInputSettings ) {
            $inputSettings = array_merge( $inputSettings, $mergeInputSettings );
        }
        if ( $mergeLabelSettings ) {
            $labelSettings = array_merge( $labelSettings, $mergeLabelSettings );
        }

        return $this->getTextbox( $inputSettings, $labelSettings );
    }

    /**
     * Get the zip code
     *
     * @param string $value
     * @param string $defaultValue
     * @param array|null $mergeInputSettings
     * @param array|null $mergeLabelSettings
     * @param array|null $mergeOptions
     * @return string
     */
    public function getZipCode( $value, $defaultValue = '', $mergeInputSettings = null, $mergeLabelSettings = null, $mergeOptions = null )
    {
        $inputSettings = array(
            'value' => $value,
            'defaultValue' => $defaultValue,
            'name' => 'zipCode',
        );

        $labelSettings = array(
            'text' => 'Zip Code',
        );

        $options = array(
            'attributes' => array(
                'class' => 'form-item--small'
            )
        );

        if ( $mergeInputSettings ) {
            $inputSettings = array_merge( $inputSettings, $mergeInputSettings );
        }
        if ( $mergeLabelSettings ) {
            $labelSettings = array_merge( $labelSettings, $mergeLabelSettings );
        }
        if ( $mergeOptions ) {
            $options = array_merge( $options, $mergeOptions );
        }

        return $this->getTextbox( $inputSettings, $labelSettings, $options );
    }

    /**
     * Get the last four ssn
     *
     * @param string $value
     * @param string $defaultValue
     * @param array|null $mergeInputSettings
     * @param array|null $mergeLabelSettings
     * @param array|null $mergeOptions
     * @return string
     */
    public function getLastFourSSN( $value, $defaultValue = '', $mergeInputSettings = null, $mergeLabelSettings = null, $mergeOptions = null )
    {
        $inputSettings = array(
            'value' => $value,
            'defaultValue' => $defaultValue,
            'name' => 'lastFourSSN',
        );

        $labelSettings = array(
            'text' => 'Last 4 SSN',
        );

        $options = array(
            'attributes' => array(
                'class' => 'form-item--small'
            )
        );

        if ( $mergeInputSettings ) {
            $inputSettings = array_merge( $inputSettings, $mergeInputSettings );
        }
        if ( $mergeLabelSettings ) {
            $labelSettings = array_merge( $labelSettings, $mergeLabelSettings );
        }
        if ( $mergeOptions ) {
            $options = array_merge( $options, $mergeOptions );
        }

        return $this->getTextbox( $inputSettings, $labelSettings, $options );
    }

//    /**
//     * Get the short description
//     *
//     * @param string $value
//     * @param string $defaultValue
//     * @return string
//     */
//    public function getShortDescription( $value, $defaultValue )
//    {
//        $inputSettings = array(
//            'value' => $value,
//            'defaultValue' => $defaultValue,
//            'name' => 'shortDescription',
//        );
//
//        $labelSettings = array(
//            'text' => 'Short Description',
//        );
//
//        $options = array(
//            'attributes' => array(
//                'class' => 'form-item--medium'
//            )
//        );
//
//        return $this->getTextbox( $inputSettings, $labelSettings, $options );
//    }

    /**
     * Get the bio
     *
     * @param string $value
     * @param string $defaultValue
     * @return string
     */
    public function getBio( $value, $defaultValue )
    {
        $inputSettings = array(
            'value' => $value,
            'defaultValue' => $defaultValue,
            'name' => 'bio',
        );

        $labelSettings = array(
            'text' => 'Bio',
        );

        $options = array(
            'attributes' => array(
                'class' => 'form-item--large'
            )
        );

        return $this->getTextarea( $inputSettings, $labelSettings, $options );
    }

    /**
     * Get an image file upload
     *
     * @param string $value
     * @param string $name
     * @param string $text
     * @return string
     */
    public function getImageFileUpload( $value, $name, $text )
    {
        $inputSettings = array(
            'value' => $value,
            'name' => $name,
        );

        $labelSettings = array(
            'text' => $text,
        );

        return $this->getFileUpload( $inputSettings, $labelSettings );
    }

    /**
     * Get the response status
     *
     * @param string $value
     * @param string $defaultValue
     * @param array|null $mergeInputSettings
     * @param array|null $mergeLabelSettings
     * @param array|null $mergeOptions
     * @return string
     */
    public function getResponseStatus( $value, $defaultValue, $mergeInputSettings = null, $mergeLabelSettings = null, $mergeOptions = null )
    {
        $items = array(
            '' => array( 'value' => '', 'text' => '' ),
            'draft' => array( 'value' => 'draft', 'text' => 'Draft' ),
            'active' => array( 'value' => 'active', 'text' => 'Active' ),
            'inactive' => array( 'value' => 'inactive', 'text' => 'Inactive' ),
            'deleted' => array( 'value' => 'deleted', 'text' => 'Deleted' ),
        );

        $inputSettings = array(
            'value' => $value,
            'defaultValue' => $defaultValue,
            'name' => 'responseStatus',
            'items' => $items,
        );

        $labelSettings = array(
            'text' => 'Status',
        );

        $options = array(
            'attributes' => array(
                'class' => 'form-item--small'
            )
        );

        if ( $mergeInputSettings ) {
            $inputSettings = array_merge( $inputSettings, $mergeInputSettings );
        }

        if ( $mergeLabelSettings ) {
            $labelSettings = array_merge( $labelSettings, $mergeLabelSettings );
        }

        if ( $mergeOptions ) {
            $options = array_merge( $options, $mergeOptions );
        }

        return $this->getSelect( $inputSettings, $labelSettings, $options );
    }

    /**
     * Get the response type
     *
     * @param string $value
     * @param string $defaultValue
     * @param array|null $mergeInputSettings
     * @param array|null $mergeLabelSettings
     * @param array|null $mergeOptions
     * @return string
     */
    public function getResponseType( $value, $defaultValue, $mergeInputSettings = null, $mergeLabelSettings = null, $mergeOptions = null )
    {
        $items = array(
            '' => array( 'value' => '', 'text' => '' ),
            'video' => array( 'value' => 'video', 'text' => 'Video' ),
            'image' => array( 'value' => 'image', 'text' => 'Image' ),
        );

        $inputSettings = array(
            'value' => $value,
            'defaultValue' => $defaultValue,
            'name' => 'responseType',
            'items' => $items,
        );

        $labelSettings = array(
            'text' => 'Media',
        );

        $options = array(
            'attributes' => array(
                'class' => 'form-item--small'
            )
        );

        if ( $mergeInputSettings ) {
            $inputSettings = array_merge( $inputSettings, $mergeInputSettings );
        }

        if ( $mergeLabelSettings ) {
            $labelSettings = array_merge( $labelSettings, $mergeLabelSettings );
        }

        if ( $mergeOptions ) {
            $options = array_merge( $options, $mergeOptions );
        }

        return $this->getSelect( $inputSettings, $labelSettings, $options );
    }

    /**
     * Get the hasValue select list
     *
     * @param string $value
     * @param string $defaultValue
     * @param array|null $mergeInputSettings
     * @param array|null $mergeLabelSettings
     * @param array|null $mergeOptions
     * @return string
     */
    public function getPostType( $value, $defaultValue, $mergeInputSettings = null, $mergeLabelSettings = null, $mergeOptions = null )
    {
        $items = array(
            'any' => array( 'value' => '', 'text' => '' ),
            'response' => array( 'value' => 'response', 'text' => 'Response' ),
            'content' => array( 'value' => 'content', 'text' => 'Content' ),
        );

        $inputSettings = array(
            'value' => $value,
            'defaultValue' => $defaultValue,
            'name' => 'postType',
            'items' => $items,
        );

        $labelSettings = array(
            'text' => 'Post Type',
        );

        $options = array(
            'attributes' => array(
                'class' => 'form-item--small'
            )
        );

        if ( $mergeInputSettings ) {
            $inputSettings = array_merge( $inputSettings, $mergeInputSettings );
        }

        if ( $mergeLabelSettings ) {
            $labelSettings = array_merge( $labelSettings, $mergeLabelSettings );
        }

        if ( $mergeOptions ) {
            $options = array_merge( $options, $mergeOptions );
        }

        return $this->getSelect( $inputSettings, $labelSettings, $options );
    }

    /**
     * Get the featured
     *
     * @param string $value
     * @param string $defaultValue
     * @return string
     */
    public function getFeatured( $value, $defaultValue )
    {
        $items = array(
            '' => array( 'value' => '', 'text' => '' ),
            'yes' => array( 'value' => 'yes', 'text' => 'Yes' ),
            'no' => array( 'value' => 'no', 'text' => 'No' ),
        );

        $inputSettings = array(
            'value' => $value,
            'defaultValue' => $defaultValue,
            'name' => 'featured',
            'items' => $items,
        );

        $labelSettings = array(
            'text' => 'Featured',
        );

        $options = array(
            'attributes' => array(
                'class' => 'form-item--small'
            )
        );

        return $this->getSelect( $inputSettings, $labelSettings, $options );
    }

    /**
     * Get the response featured sort order
     *
     * @param string $value
     * @param string $defaultValue
     * @param array|null $mergeInputSettings
     * @param array|null $mergeLabelSettings
     * @param array|null $mergeOptions
     * @return string
     */
    public function getResponseFeaturedSortOrder( $value, $defaultValue, $mergeInputSettings = null, $mergeLabelSettings = null, $mergeOptions = null )
    {
        $inputSettings = array(
            'value' => $value,
            'defaultValue' => $defaultValue,
            'name' => 'featuredSortOrder',
        );

        $labelSettings = array(
            'text' => 'Featured Sort Order',
        );

        $options = array(
            'attributes' => array(
                'class' => 'form-item--small'
            )
        );

        if ( $mergeInputSettings ) {
            $inputSettings = array_merge( $inputSettings, $mergeInputSettings );
        }

        if ( $mergeLabelSettings ) {
            $labelSettings = array_merge( $labelSettings, $mergeLabelSettings );
        }

        if ( $mergeOptions ) {
            $options = array_merge( $options, $mergeOptions );
        }

        return $this->getTextbox( $inputSettings, $labelSettings, $options );
    }

    /**
     * Get the description
     *
     * @param string $value
     * @param string $defaultValue
     * @param array|null $mergeInputSettings
     * @param array|null $mergeLabelSettings
     * @param array|null $mergeOptions
     * @return string
     */
    public function getDescription( $value, $defaultValue, $mergeInputSettings = null, $mergeLabelSettings = null, $mergeOptions = null )
    {
        $inputSettings = array(
            'value' => $value,
            'defaultValue' => $defaultValue,
            'name' => 'description',
        );

        $labelSettings = array(
            'text' => 'Description',
        );

        $options = array(
            'attributes' => array(
                'class' => 'form-item--medium'
            )
        );

        if ( $mergeInputSettings ) {
            $inputSettings = array_merge( $inputSettings, $mergeInputSettings );
        }

        if ( $mergeLabelSettings ) {
            $labelSettings = array_merge( $labelSettings, $mergeLabelSettings );
        }

        if ( $mergeOptions ) {
            $options = array_merge( $options, $mergeOptions );
        }

        return $this->getTextarea( $inputSettings, $labelSettings, $options );
    }

    /**
     * Get the label
     *
     * @param string $value
     * @param string $defaultValue
     * @param array|null $mergeInputSettings
     * @param array|null $mergeLabelSettings
     * @param array|null $mergeOptions
     * @return string
     */
    public function getLabel( $value, $defaultValue, $mergeInputSettings = null, $mergeLabelSettings = null, $mergeOptions = null )
    {
        $inputSettings = array(
            'value' => $value,
            'defaultValue' => $defaultValue,
            'name' => 'label',
        );

        $labelSettings = array(
            'text' => 'Label',
        );

        $options = array(
            'attributes' => array(
                'class' => 'form-item'
            )
        );

        if ( $mergeInputSettings ) {
            $inputSettings = array_merge( $inputSettings, $mergeInputSettings );
        }

        if ( $mergeLabelSettings ) {
            $labelSettings = array_merge( $labelSettings, $mergeLabelSettings );
        }

        if ( $mergeOptions ) {
            $options = array_merge( $options, $mergeOptions );
        }

        return $this->getTextbox( $inputSettings, $labelSettings, $options );
    }

    /**
     * Get the user status
     *
     * @param string $value
     * @param string $defaultValue
     * @return string
     */
    public function getUserStatus( $value, $defaultValue )
    {
        $items = array(
            '' => array( 'value' => '', 'text' => '' ),
            'draft' => array( 'value' => 'draft', 'text' => 'Draft' ),
            'active' => array( 'value' => 'active', 'text' => 'Active' ),
            'inactive' => array( 'value' => 'inactive', 'text' => 'Inactive' ),
            'revoked' => array( 'value' => 'revoked', 'text' => 'Revoked' ),
            'deleted' => array( 'value' => 'deleted', 'text' => 'Deleted' ),
        );

        $inputSettings = array(
            'value' => $value,
            'defaultValue' => $defaultValue,
            'name' => 'userStatus',
            'items' => $items,
        );

        $labelSettings = array(
            'text' => 'Status',
        );

        $options = array(
            'attributes' => array(
                'class' => 'form-item--small'
            )
        );

        return $this->getSelect( $inputSettings, $labelSettings, $options );
    }

    /**
     * Get the user revoked reason
     *
     * @param string $value
     * @param string $defaultValue
     * @return string
     */
    public function getUserRevokedReason( $value, $defaultValue )
    {
        $items = array(
            '' => array( 'value' => '', 'text' => '' ),
            'inappropriate' => array( 'value' => 'inappropriate', 'text' => 'Inappropriate' ),
            'harassment' => array( 'value' => 'harassment', 'text' => 'Harassment' ),
            'notdemo' => array( 'value' => 'notdemo', 'text' => 'Not Demo' ),
            'parental' => array( 'value' => 'parental', 'text' => 'Parental' ),
            'other' => array( 'value' => 'other', 'text' => 'Other' ),
        );

        $inputSettings = array(
            'value' => $value,
            'defaultValue' => $defaultValue,
            'name' => 'userRevokedReason',
            'items' => $items,
        );

        $labelSettings = array(
            'text' => 'Revoked Reason',
        );

        $options = array(
            'attributes' => array(
                'class' => 'form-item--small'
            )
        );

        return $this->getSelect( $inputSettings, $labelSettings, $options );
    }

    /**
     * Get the start time
     *
     * @param string $value
     * @param string $defaultValue
     * @return string
     */
    public function getStartTime( $value, $defaultValue )
    {
        $inputSettings = array(
            'value' => $value,
            'defaultValue' => $defaultValue,
            'name' => 'startTime',
        );

        $labelSettings = array(
            'text' => 'Start Time',
        );

        $options = array(
            'attributes' => array(
                'class' => 'form-item--small'
            ),
            'placeholder' => 'YYYY-MM-DD HH:MM:SS',
        );

        return $this->getTextbox( $inputSettings, $labelSettings, $options );
    }

    /**
     * Get the end time
     *
     * @param string $value
     * @param string $defaultValue
     * @return string
     */
    public function getEndTime( $value, $defaultValue )
    {
        $inputSettings = array(
            'value' => $value,
            'defaultValue' => $defaultValue,
            'name' => 'endTime',
        );

        $labelSettings = array(
            'text' => 'End Time',
        );

        $options = array(
            'attributes' => array(
                'class' => 'form-item--small'
            ),
            'placeholder' => 'YYYY-MM-DD HH:MM:SS',
        );

        return $this->getTextbox( $inputSettings, $labelSettings, $options );
    }

    /**
     * Get the featured type
     *
     * @param string $value
     * @param string $defaultValue
     * @param string $modelType
     * @return string
     */
    public function getFeaturedType( $value, $defaultValue, $modelType, $streamId = null )
    {

        $site = $this->view->site;

        $items = array();

        // Load Stream Specific Keys
        $filterBy = array();
        switch ($modelType) {
            case 'response' :
                $filterBy['stream_type'] = 'FEATURED_RESPONSES';
                break;
            case 'callenge' :
                $filterBy['stream_type'] = 'FEATURED_CHALLENGES';
                break;
            default;
                break;
        }
        $streams = $site->getStreams($filterBy);
        foreach($streams as $stream) {
            $definition = $stream->getDefinition();
            // print("\$definition => <pre>".print_r($definition,true)."</pre>");
            $featuredKey = $definition['featuredType'] ?? 'stream-'.$stream->getId();
            $featuredLabel = $stream->getLabel();
            $items[$featuredKey] = array( 'value' => $featuredKey, 'text' => $featuredLabel);
        }

        // Add default keys


        $items['maverick-stream'] = array( 'value' => 'maverick-stream', 'text' => 'Maverick Stream' );
        $items['challenge-stream'] = array( 'value' => 'challenge-stream', 'text' => 'Challenge Stream' );
        
        
        $attributes = array();
        if ($streamId) {
            $attributes['disabled'] = 'disabled';
        }

        $inputSettings = array(
            'value' => $value,
            'defaultValue' => $defaultValue,
            'name' => 'featuredType',
            'items' => $items,
            'attributes' => $attributes,
        );

        $labelSettings = array(
            'text' => 'Featured Type',
        );

        $options = array(
            'attributes' => array(
                'class' => 'form-item--small'
            )
        );

        return $this->getSelect( $inputSettings, $labelSettings, $options );
    }

    /**
     * Get the response
     *
     * @param string $value
     * @param string $defaultValue
     * @param string $size
     * @param string $type
     * @return string
     */
    public function getResponseAutocomplete( $value, $defaultValue = null, $size = '', $type = 'search', $label = null )
    {
        $site = $this->view->site;
        $currentResponse = $value ? $site->getResponse( $value ) : null;
        $defaultResponse = $defaultValue ? $site->getResponse( $defaultValue ) : null;
        $inputSettings = array(
            'value' => $currentResponse ? $currentResponse->getId() : '',
            'defaultValue' => $defaultResponse ? $defaultResponse->getId() : '',
            'name' => 'responseTitle',
            'postContent' => $this->getHiddenSimple( 'responseId', ( $value ? $value : $defaultValue ) ),
            'attributes' => array(
                'data-auto-complete-url' => '/autocomplete/responses',
                'data-auto-complete-action' => $type
            )
        );

        $labelSettings = array(
            'text' => $label ?? 'Response',
        );

        $sizeClass = $size ? " form-item--".$size : "";
        $sizeClass = "";
        $options = array(
            'attributes' => array(
                'class' => 'auto-complete'.$sizeClass,
                'style' => 'width: 100%;'
            )
        );

        return $this->getTextbox( $inputSettings, $labelSettings, $options );
    }

    /**
     * Get the user using autocomplete
     *
     * @param string $value
     * @param string $defaultValue
     * @param string $size
     * @param string $type
     * @return string
     */
    public function getUserAutocomplete( $value, $defaultValue = null, $size = '', $type = 'search' )
    {
        $site = $this->view->site;

        $currentUser = $value ? $site->getUserByUsername( $value ) : null;
        $defaultUser = $defaultValue ? $site->getUserByUsername( $defaultValue ) : null;

        $inputSettings = array(
            'value' => $currentUser ? $currentUser->getUsername() : '',
            'defaultValue' => $defaultUser ? $defaultUser->getUsername() : '',
            'name' => 'username',
            'postContent' => $this->getHiddenSimple( 'userId', ( $value ? $value : $defaultValue ) ),
            'attributes' => array(
                'data-auto-complete-url' => '/autocomplete/users',
                'data-auto-complete-action' => $type
            )
        );

        $labelSettings = array(
            'text' => 'User',
        );

        $sizeClass = $size ? " form-item--".$size : "";
        $options = array(
            'attributes' => array(
                'class' => 'auto-complete'.$sizeClass
            )
        );

        return $this->getTextbox( $inputSettings, $labelSettings, $options );
    }

    /**
     * Get the hide from stream
     *
     * @param string $value
     * @param string $defaultValue
     * @return string
     */
    public function getHideFromStreams( $value, $defaultValue )
    {
        $items = array(
            '0' => array( 'value' => '0', 'text' => 'No' ),
            '1' => array( 'value' => '1', 'text' => 'Yes (Hide Content)' ),
        );

        $inputSettings = array(
            'value' => $value,
            'defaultValue' => $defaultValue,
            'name' => 'hideFromStreams',
            'items' => $items,
        );

        $labelSettings = array(
            'text' => 'Hide from Streams (Challenges & Featured tabs)',
        );

        $options = array(
            'attributes' => array(
                'class' => 'form-item--small'
            )
        );

        return $this->getSelect( $inputSettings, $labelSettings, $options );
    }

    /**
     * Get the collect information consent
     *
     * @param string $value
     * @param string $defaultValue
     * @return string
     */
    public function getConsentCollectInformation( $value, $defaultValue = '' )
    {
        $text = 'I agree to Maverick’s <a href="https://genmaverick.com/privacy" target="_blank">Privacy Policy</a>.';

        return $this->getCheckboxSimple( 'consentCollect', $text, $value, $defaultValue );
    }

    /**
     * Get the share information consent
     *
     * @param string $value
     * @param string $defaultValue
     * @return string
     */
    public function getConsentShareInformation( $value, $defaultValue = '' )
    {
        $text = 'I authorize the app to share my kid\'s personal information with other users in the app and the other social media platforms.';

        return $this->getCheckboxSimple( 'consentShare', $text, $value, $defaultValue );
    }

    /**
     * Get the sort logic list
     *
     * @param string $value
     * @param string $defaultValue
     * @return string
     */
    public function getSortLogic( $value, $defaultValue )
    {
        $items = array(
            'custom' => array( 'value' => 'custom', 'text' => 'Custom' ),
            'random' => array( 'value' => 'random', 'text' => 'Random' ),
            'mostRecent' => array( 'value' => 'mostRecent', 'text' => 'Most Recent' ),
        );

        $inputSettings = array(
            'value' => $value,
            'defaultValue' => $defaultValue,
            'name' => 'sortLogic',
            'items' => $items,
        );

        $labelSettings = array(
            'text' => 'Sort Logic',
        );

        $options = array(
            'attributes' => array(
                'class' => 'form-item--sort-logic'
            )
        );

        return $this->getSelect( $inputSettings, $labelSettings, $options );
    }


    /**
     * Get the stream display limit
     *
     * @param string $value
     * @param string $defaultValue
     * @return string
     */
    public function getDisplayLimit( $value, $defaultValue = 10 )
    {
        $items = array(
            '' => array( 'value' => '', 'text' => '' ),
        );
        foreach (range(1, 25) as $i) {
            $items[$i] = array( 'value' => $i, 'text' => $i );
        }

        $inputSettings = array(
            'value' => $value,
            'defaultValue' => $defaultValue,
            'name' => 'displayLimit',
            'items' => $items,
        );

        $labelSettings = array(
            'text' => 'Display Limit',
        );

        $options = array(
            'attributes' => array(
                'class' => 'form-item'
            )
        );

        return $this->getSelect( $inputSettings, $labelSettings, $options );
    }

    /**
     * Get the stream delay
     *
     * @param string $value
     * @param string $defaultValue
     * @return string
     */
    public function getDelay( $value, $defaultValue = 10 )
    {
        $items = array();
        $items[0] = array( 'value' => 0, 'text' => "no delay" );
        foreach (range(15, 1440, 15) as $i) {
            $items[$i] = array( 'value' => $i, 'text' => $this->_convertToHoursMins($i) );
        }

        $inputSettings = array(
            'value' => $value,
            'defaultValue' => $defaultValue,
            'name' => 'delay',
            'items' => $items,
        );

        $labelSettings = array(
            'text' => 'Delay',
        );

        $options = array(
            'attributes' => array(
                'class' => 'form-item'
            )
        );

        return $this->getSelect( $inputSettings, $labelSettings, $options );
    }


    /**
     * Get the stream rotate frequency
     *
     * @param string $value
     * @param string $defaultValue
     * @return string
     */
    public function getRotateFrequency( $value, $defaultValue = 0 )
    {
        // die('value '.$value);
        $items = array(
            '0' => array( 'value' => 0, 'text' => 'never' ),
        );
        foreach (range(1, 24) as $i) {
            $items[$i] = array( 'value' => $i, 'text' => "every $i ".($i == 1 ? 'hour' : 'hours') );
        }

        $inputSettings = array(
            'value' => $value,
            'defaultValue' => $defaultValue,
            'name' => 'rotateFrequency',
            'items' => $items,
        );

        $labelSettings = array(
            'text' => 'Rotate Frequency',
        );

        $options = array(
            'attributes' => array(
                'class' => 'form-item'
            )
        );

        return $this->getSelect( $inputSettings, $labelSettings, $options );
    }


    /**
     * Get the stream rotate count
     *
     * @param string $value
     * @param string $defaultValue
     * @return string
     */
    public function getRotateCount( $value, $defaultValue )
    {
        $items = array(
            '0' => array( 'value' => '0', 'text' => 'none' ),
        );
        foreach (range(1, 50) as $i) {
            $items[$i] = array( 'value' => $i, 'text' => $i );
        }

        $inputSettings = array(
            'value' => $value,
            'defaultValue' => $defaultValue,
            'name' => 'rotateCount',
            'items' => $items,
        );

        $labelSettings = array(
            'text' => 'Number to Rotate',
        );

        $options = array(
            'attributes' => array(
                'class' => 'form-item'
            )
        );

        return $this->getSelect( $inputSettings, $labelSettings, $options );
    }

    /**
     * Get the reorder on save checkbox
     *
     * @param string $value
     * @param string $defaultValue
     * @return string
     */
    public function getRotateOnSave( $value = false, $defaultValue = false )
    {
        $label = 'Rotate on save';

        return $this->getCheckboxSimple( 'rotateOnSave', $label, $value, $defaultValue );
    }

    /**
     * Get the Stream Settings form
     *
     * @param string $stream
     * @return string
     */
    public function getStreamSettingsForm( $stream ) {

        $output = "";

        $label = $stream->getLabel();
        $status = $stream->getStatus();
        $definition = $stream->getDefinition();
        $streamType = $stream->getStreamType();
        $displayLimit = $definition['logic']['displayLimit'] ?? BeMaverick_Stream::DEFAULT_DISPLAY_LIMIT;
        $delay = $definition['logic']['delay'] ?? BeMaverick_Stream::DEFAULT_DELAY;
        $paginated = $stream->getPaginated();
        $formItems = array();
        $formItems[] = $this->getLabel( $label, '' );
        $formItems[] = $this->getContentStatus( $status, 'active', 'form-item' );
        if(in_array($streamType, array('LATEST_RESPONSES'))) {
            $formItems[] = $this->getDelay( $delay, BeMaverick_Stream::DEFAULT_DELAY);
        }
        if(in_array($streamType, array('FEATURED_CHALLENGES', 'FEATURED_RESPONSES', 'LATEST_RESPONSES'))) {
            $formItems[] = $this->getDisplayLimit( $displayLimit, BeMaverick_Stream::DEFAULT_DISPLAY_LIMIT);
            $formItems[] = $this->getPaginated( $paginated, false, "Display \"See More\" link" );
        }

        $output .= "<div class='filter'>";
            $output .= "<h3>Stream Settings</h3>";
            $output .= "<p>Edit the label for the stream, turn it on/off, and manage how many responses are displayed in app</p>";
            $output .= $this->getList( $formItems );
            $output .= "<hr />";
        $output .= "</div>";

        return $output;

    }

    /**
     * Get the Stream Rotation form
     *
     * @param string $stream
     * @return string
     */
    public function getStreamRotationForm( $stream ) {

        $output = "";

        $definition = $stream->getDefinition();
        $rotateFrequency = $definition['logic']['rotateFrequency'] ?? BeMaverick_Stream::DEFAULT_ROTATE_FREQUENCY;
        $rotateCount = $definition['logic']['rotateCount'] ?? BeMaverick_Stream::DEFAULT_ROTATE_COUNT;
        $lastRotated = $definition['logic']['lastRotated'] ?? null;
        $nextRotate = ($lastRotated && $rotateFrequency > 0) ? ($lastRotated + ($rotateFrequency * 60 * 60) ) : null;

        $formItems = array();
        $formItems[] = $this->getRotateFrequency( $rotateFrequency, $rotateFrequency ?? BeMaverick_Stream::DEFAULT_ROTATE_FREQUENCY);
        $formItems[] = $this->getRotateCount( $rotateCount, BeMaverick_Stream::DEFAULT_ROTATE_COUNT);
        $formItems[] = $this->getRotateOnSave( false, false);
        
        $output .= "<div class='filter'>";
            $output .= "<h3>Rotation</h3>";
            $output .= "<p>Manage when and how many responses are moved from the front of the stream to the end</p>";
            $output .= $this->getList( $formItems );
            $output .= "<div>Last rotated: " . ( $lastRotated ? date('Y-m-d h:i a', $lastRotated) : 'n/a' ) . "</div>";
            $output .= "<div>Next rotation: " . ( $nextRotate ? date('Y-m-d h:i a', $nextRotate) : 'n/a' ) . "</div>";
            $output .= "<hr />";
        $output .= "</div>";

        return $output;

    }

    /**
     * Get the Stream Challenge form
     *
     * @param string $stream
     * @return string
     */
    public function getStreamChallengeForm( $stream, $input = null ) {

        $site = $this->view->site;

        $output = "";

        $definition = $stream->getDefinition();
        $challengeId = $definition['challengeId'] ?? null;
        $challenge = $challengeId ? $site->getChallenge( $challengeId ) : null;
        // die('<pre>definition '.print_r($definition,true));
        // die('<pre>challenge '.print_r($challenge,true));

        $formItems = array();
        $formItems[] = $this->getChallengeAutocomplete( $challengeId, null, 'auto', 'search', 'Search by Challenge Title, User, or ID');
        
        $output .= "<div class=''>";
            $output .= "<h3>Challenge</h3>";
            $output .= "<p>Select a Challenge for the Stream</p>";
            $output .= $this->getList( $formItems );
            if($challenge) {
                $user = $site->getUser( $challenge->getUserId() );
                $challengeTitle = $challenge->getTitle();
                $username = $user->getUsername();
                $output .= "<p><b>$challengeTitle</b> by <b>$username</b></p>";
            };
            $output .= "<hr />";
        $output .= "</div>";

        return $output;

    }

    /**
     * Get the Stream Deeplink form
     *
     * @param string $stream
     * @return string
     */
    public function getStreamDeeplinkForm( $stream, $input = null ) {
        $output = "";
        $definition = $stream->getDefinition();
        $uri = $definition['link']['deeplink'] ?? null;
        $modelType = $definition['link']['modelType'] ?? null;
        $modelId = $definition['link']['modelId'] ?? null;
        // die('definition '.print_r($definition,true));
        $formItems = array();
        $formItems[] = $this->getDeeplinkModelType( $modelType, 'stream');
        $formItems[] = $this->getDeeplinkModelId( $modelId, null);

        $output .= "<div class='filter'>";
        $output .= "<h3>Deeplink</h3>";
        $output .= "<p>Manage where this stream links to</p>";
        $output .= $this->getList( $formItems );
        $output .= "<div>URI: $uri</div>";
        $output .= "<hr />";
        $output .= "</div>";
        return $output;
    }

    /**
     * Get the Stream Deeplink form
     *
     * @param string $stream
     * @return string
     */
    public function getStreamImageForm( $stream, $input = null ) {

        $output = "";

        $defaultImage = null;

        if($input) {
            $defaultImage = $input->image ?? null;
        }

        $definition = $stream->getDefinition();
        $image = $definition['image'] ?? null;
        $url = $image['url'] ?? null;

        $formItems = array();
        $formItems[] = $this->getImageFileUpload( $defaultImage, 'image', 'Image');
        
        $output .= "<div class='filter'>";
            $output .= "<h3>Image</h3>";
            $output .= "<p>Upload an image</p>";
            $output .= $this->getList( $formItems );
            $output .= $url ? "<p><a href='$url' target='_blank'>$url</a></p>" : "";
            $output .= $url ? "<p><img src='$url' style='max-width: 100px' /></p>" : "";
            $output .= "<hr />";
        $output .= "</div>";

        return $output;

    }


    /**
     * Get the Stream Table Styles
     *
     * @param string $stream
     * @return string
     */
    public function getStreamTableStyles( $stream ) {

        $definition = $stream->getDefinition();
        $rotateCount = $definition['logic']['rotateCount'] ?? BeMaverick_Stream::DEFAULT_ROTATE_COUNT;
        $displayLimit = $definition['logic']['displayLimit'] ?? BeMaverick_Stream::DEFAULT_DISPLAY_LIMIT;

        // die($rotateCount);

        $output = "<style>
            div.table-display-limit table tr:nth-child({$rotateCount}n) {
                border-bottom: 4px dashed #8dcfe8;
            }
            div.table-display-limit table tr:nth-child($displayLimit) {
                border-bottom: 8px dashed #428bca;
                position: relative;
            }
        </style>";

        return $output;
    }


    /**
     * Get the deep link model type
     *
     * @param string $value
     * @param string $defaultValue
     * @return string
     */
    public function getDeeplinkModelType( $value, $defaultValue )
    {
        $items = array(
            '' => array( 'value' => '', 'text' => '' ),
            'streams' => array( 'value' => 'streams', 'text' => 'Streams' ),
            'challenges' => array( 'value' => 'challenges', 'text' => 'Challenges' ),
            'responses' => array( 'value' => 'responses', 'text' => 'Responses' ),
            'users' => array( 'value' => 'users', 'text' => 'Users' ),
            'tabs' => array( 'value' => 'main', 'text' => 'Tabs' ),
        );

        $inputSettings = array(
            'value' => $value,
            'defaultValue' => $defaultValue,
            'name' => 'deeplinkModelType',
            'items' => $items,
        );

        $labelSettings = array(
            'text' => 'Deeplink Type',
        );

        $options = array(
            'attributes' => array(
                'class' => 'form-item'
            )
        );

        return $this->getSelect( $inputSettings, $labelSettings, $options );
    }


    /**
     * Get the deeplink model id
     *
     * @param string $value
     * @param string $defaultValue
     * @return string
     */
    public function getDeeplinkModelId( $value, $defaultValue )
    {
        $inputSettings = array(
            'value' => $value,
            'defaultValue' => $defaultValue,
            'name' => 'deeplinkModelId',
        );

        $labelSettings = array(
            'text' => 'Deeplink Id',
        );

        $options = array(
            'attributes' => array(
                'class' => 'form-item--small'
            ),
            'placeholder' => '0',
        );

        return $this->getTextbox( $inputSettings, $labelSettings, $options );
    }

    /**
     * Get the stream type
     *
     * @param string $value
     * @param string $defaultValue
     * @return string
     */
    public function getStreamType( $value, $defaultValue )
    {
        $items = array(
            '' => array( 'value' => '', 'text' => '- select -' ),
        );
        $streamTypes = BeMaverick_Stream::STREAM_TYPES;
        foreach($streamTypes as $key => $text) {
            $items[$key] = array( 'value' => $key, 'text' => $text );
        }

        $inputSettings = array(
            'value' => $value,
            'defaultValue' => $defaultValue,
            'name' => 'streamType',
            'items' => $items,
        );

        $labelSettings = array(
            'text' => 'Type',
        );

        $options = array(
            'attributes' => array(
                'class' => 'form-item'
            )
        );
        return $this->getSelect( $inputSettings, $labelSettings, $options );
    }


    /**
     * Get the paginated flag
     *
     * @param string $value
     * @param string $defaultValue
     * @return string
     */
    public function getPaginated( $value, $defaultValue = false, $customText = null )
    {
        $text = $customText ?? 'Paginated';

        return $this->getCheckboxSimple( 'paginated', $text, $value, $defaultValue );
    }

    private function _convertToHoursMins($time, $format = '%2d hrs %02d min') {
        if ($time < 1) {
            return;
        }
        $hours = floor($time / 60);
        $minutes = ($time % 60);
        return sprintf($format, $hours, $minutes);
    }


    public function getNameValue( $value = array(), $name = array(), $options = array() )
    {

        $htmlElement = $this->view->htmlElement();
        $formatForm = $this->view->formatForm();
        $value = new Sly_DataObject( $value );
        $name = new Sly_DataObject( $name );
        $options = new Sly_DataObject( $options );


        $valueAttributes = $value->getAttributes( array() );

        $width = $value->getWidth();
        if ( $width ) {
            $valueAttributes = $this->view->formatUtil()->addItemToAttributes( $valueAttributes , 'class', 'span'.$width );
        }
        $valueAttributes = $this->view->formatUtil()->addItemToAttributes( $valueAttributes , 'class', 'control-value' );

        $returnType = $options->getReturnType();
        $controlWrap = $options->getControlWrap( true );

        $pieces = array();
        // $pieces[] = $this->wrapContent( $this->_getName( $name ), $name );
        $pieces[] = $this->wrapContent( $this->_getLabel( $name ), $name );

        if ( $controlWrap ) {
            $pieces[] = '<div class="controls">';
        }

        $text = strlen($value->getText('')) > 0 ? $htmlElement->getContainingTag( 'span', $value->getText(''), $valueAttributes ) : '';
        $pieces[] = $this->wrapContent( $text, $value );
        $pieces[] = $this->_getHelp( $options );
        if ( $controlWrap ) {
            $pieces[]  = '</div>';
        }

        $title = $this->wrapContent(join( $pieces, '' ), $options);


        if ( $returnType == 'title' ) {
            return $title;
        } else {
            $classes = $this->getItemClasses( 'control-group form-group name-value' );
            $optionAttributes = $options->getAttributes( array() );
            $optionAttributes = $this->view->formatUtil()->addItemToAttributes( $optionAttributes , 'class', $classes );
            return array(
                'title' => $title,
                'itemAttributes' => $optionAttributes
            );
        }
    }

    public function getNameValueSimple( $value, $name, $options = array() )
    {
        return $this->getNameValue( array( 'text' => $value ), array( 'text' => $name ), $options );
    }

    public function getHashtagsValue( $hashtags, $name = 'Hashtags', $options = array() )
    {
        $value = is_array($hashtags)
            ? implode(', ',array_map(function ($hashtag) { return '#'.$hashtag; }, $hashtags))
            : '<em>none</em>';
        return $this->getNameValueSimple( $value, $name, $options );
    }

    public function getIsEmailVerified( $isEmailVerified, $name = 'Is Email Verified', $options = array() )
    {
        $value = $isEmailVerified ? 'Yes' : 'No';
        return $this->getNameValueSimple( $value, $name, $options );
    }

    public function getIsVerified( $value, $defaultValue, $text = null, $options = array() )
    {
        $text = (!is_null($text)) ? $text : "Is Verified <img style='height: 20px; vertical-align: bottom;' src='/images/verified.png' />";
        $value = (!is_null($value)) ? $value : $defaultValue;
        return $this->getCheckboxSimple( 'isVerified', $text, $value, $defaultValue );
    }

    //this is private since it expects a Sly_DataObject
    private function _getLabel( $label, $id = '' )
    {

        if ( $label->getText() ) {
            if ( ! $label->getAttributes() ) {
                $attributes = $this->view->formatUtil()->addItemToAttributes( $label->getAttributes(array()), 'class' , 'control-label' );
            } else {
                $attributes = $label->getAttributes( array() );
            }
            return $this->view->htmlElement()->getLabel( $label->getText(), $id, $attributes ).' ';
        } else {
            return '';
        }
    }

    //this is private since it expects a Sly_DataObject
    private function _getHelp( $options )
    {
        if ( $options->getHelp() ) {
            return '<p class="help-block">'.$options->getHelp().'</p> ';
        } else {
            return '';
        }
    }

}
