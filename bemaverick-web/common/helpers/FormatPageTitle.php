<?php
/**
 * Class for formatting page title
 *
 * @category BeMaverick
 * @package  BeMaverick_View_Helper
 */
class BeMaverick_View_Helper_FormatPageTitle
{

    /**
     * The view object that created this helper object.
     *
     * @var Zend_View
     */
    public $view;

    /**
     * Returns this helper
     *
     * @return BeMaverick_View_Helper_FormatPageTitle
     */
    public function formatPageTitle()
    {
        return $this;
    }

    /**
     * Get title heading text
     *
     * @param Sly_Config_Page $pageConfig
     * @return string
     */
    public function getTitleHeadingText( $pageConfig = null )
    {
        $pageConfig = $pageConfig ? $pageConfig : $this->view->pageConfig;
        return $this->replaceTitlePieces( $pageConfig->getTitleHeadingText(), $pageConfig );
    }

    /**
     * Get title text
     *
     * @param Sly_Config_Page $pageConfig
     * @return string
     */
    public function getTitle( $pageConfig = null )
    {
        $pageConfig = $pageConfig ? $pageConfig : $this->view->pageConfig;
        return $this->replaceTitlePieces( $pageConfig->getTitle(), $pageConfig );
    }

    /**
     * Replace any tokens that are in the title
     *
     * @param string $text
     * @param Sly_Config_Page $pageConfig
     * @return string
     */
    public function replaceTitlePieces( $text, $pageConfig = null )
    {
        $pageConfig = $pageConfig ? $pageConfig : $this->view->pageConfig;
        $content = $this->view->content;
        $post = $this->view->post;
        $input = $this->view->input;
        $user = $this->view->user;
        $response = $this->view->response;
        $challenge = $this->view->challenge;
        $translator = $this->view->translator;

        if ( $content ) {
            $title = $content->getTitle();
            $text = str_replace( ':postTitle', $title, $text );
        }

        if ( $post ) {
            $title = $post['title']['rendered'];
            $text = str_replace( ':postTitle', $title, $text );
        }

        if ( $user ) {
            $userProfileDetailsTitles = array(
                'responses' => '',
                'activity' => $translator->_( 'Activity' ),
                'badged' => $translator->_( 'Badged' ),
                'overview' => $translator->_('Overview' ),
                'saved' => $translator->_( 'Saved' ),
            );

            $userProfileDetailsTab = $input && $input->userProfileDetailsTab && isset( $userProfileDetailsTitles[$input->userProfileDetailsTab] ) ? $userProfileDetailsTitles[$input->userProfileDetailsTab] : '';

            $username = $user->getUsername();

            $text = str_replace( ':userUsernamePossessive', $username.'\'s', $text );
            $text = str_replace( ':userUsername', $username, $text );
            $text = str_replace( ':userProfileDetailsTab', $userProfileDetailsTab, $text );
        }

        if ( $response ) {

            $responseChallenge = $response->getChallenge();
            $responseChallengeTitle =  $responseChallenge ? $responseChallenge->getTitle() : $response->getTitle();

            $responseUser = $response->getUser();
            $responseUsername = $responseUser->getUsername();

            $text = str_replace( ':responseChallengeTitle', $responseChallengeTitle, $text );
            $text = str_replace( ':responseUserUsername', $responseUsername, $text );

        }
        if ( $challenge ) {

            $challengeUser = $challenge->getUser();

            $text = str_replace( ':challengeTitle', $challenge->getTitle(), $text );
            $text = str_replace( ':challengeUserName', $challengeUser->getName(), $text );

        }

        return trim( $text );
    }

    /**
     * get the page title for the <title> tag
     *
     * @param Sly_Config_Page $pageConfig
     * @param boolean $usePrefix
     * @return string
     */
    public function getDocumentTitle( $pageConfig = null, $usePrefix = true )
    {
        $pageConfig = $pageConfig ? $pageConfig : $this->view->pageConfig;
        $titleChunks = array();
        if ( $usePrefix && $pageConfig->useTitlePrefix()  ) {
            $titleChunks[] = $pageConfig->getTitlePrefix();
        }

        $titleChunks[] = $this->getTitle( $pageConfig );
        $titleChunks = array_reverse( $titleChunks );
        $pageTitleInfo = htmlentities( join( $titleChunks, $pageConfig->getTitlePrefixDelimiter() ) );

        return $pageTitleInfo;
    }

    /**
     * Set the view to this object
     *
     * @param Zend_View_Interface $view
     * @return void
     */
    public function setView( Zend_View_Interface $view )
    {
        $this->view = $view;
    }

}
