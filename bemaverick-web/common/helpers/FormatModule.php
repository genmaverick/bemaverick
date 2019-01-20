<?php

require_once( SLY_ROOT_DIR . '/lib/Sly/DataObject.php' );

/**
 * Class for formatting Modules
 *
 * @category BeMaverick
 * @package  BeMaverick_View_Helper
 */

class BeMaverick_View_Helper_FormatModule
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
     * @return BeMaverick_View_Helper_FormatModule
     */
    public function formatModule()
    {
        return $this;
    }

    /**
     * prefix css class names
     *
     * @param string $name
     * @param string[] $prefixes
     * @param string $delimiter
     * @param boolean $join
     * @return string[]|string
     */
    public function getPrefixedClasses( $name = '', $prefixes = array(), $delimiter = '__', $join = false )
    {
        $classNames = array();
        $delimiter = $name ? $delimiter : '';
        foreach( $prefixes as $prefix ) {
            $classNames[] = $prefix.$delimiter.$name;
        }
        if ( $join ) {
            return join( ' ', $classNames );
        } else {
            return $classNames;
        }
    }

    /**
     * get the markup for a module
     *
     * @param array $config
     * @return string
     */
    public function getModule( $config = array() )
    {
        $html = '';
        $configObj = new Sly_DataObject( $config );

        $classPrefixes = $configObj->getClassPrefixes( array( 'content-module' ) );

        $delimiter = $configObj->getDelimiter( '__' );

        $classNames = $this->getPrefixedClasses( '', $classPrefixes );
        $header = $this->getSection( $configObj->getHeader( array() ), $classPrefixes, 'hd', $delimiter );
        $body = $this->getSection( $configObj->getBody( array() ), $classPrefixes, 'bd', $delimiter );
        $footer = $this->getSection( $configObj->getFooter( array() ), $classPrefixes, 'ft', $delimiter );

        $attributes = $configObj->getAttributes( array() );
        $attributes = $this->view->formatUtil()->addItemToAttributes( $attributes, 'class', join( ' ', $classNames ) );

        $html .= '
            <div '.$this->view->htmlAttributes( $attributes ).'>
                '.$header.'
                '.$body.'
                '.$footer.'
            </div>
        ';

        return $html;
    }

    /**
     * get the markup for a section of a module
     *
     * @param Sly_DataObject $config
     * @param string[] $classPrefixes
     * @param string $sectionName
     * @param string $classDelimiter
     * @return string
     */
    public function getSection( $config = array(), $classPrefixes = array(), $sectionName = '', $classDelimiter = '__' )
    {
        $configObj = new Sly_DataObject( $config );
        $content = $configObj->getContent();
        $attributes = $configObj->getAttributes( array() );

        $classNames = $this->getPrefixedClasses( $sectionName, $classPrefixes, $classDelimiter );
        $attributes = $this->view->formatUtil()->addItemToAttributes( $attributes, 'class', join( ' ', $classNames ) );

        $html = '';
        if ($content) {
            $html = '
                <div '.$this->view->htmlAttributes( $attributes ).'>
                '.$content.'
                </div>
            ';
        }
        return $html;
    }

    /**
     * get the header markup for a "basic-module" module
     *
     * @param array $config
     * @return string
     */
    public function getBasicModuleHeader( $config = array() )
    {
        $configObj = new Sly_DataObject( $config );

        $returnLinkUrl = $configObj->getReturnLinkUrl();
        $returnLinkTitle = $configObj->getReturnLinkTitle( '' );
        $returnLinkTransitionType = $configObj->getReturnLinkTransitionType( 'from-right' );
        $titleTag = $configObj->getTitleTag( 'h1' );
        $title = $configObj->getTitle( '' );

        $flexSpacer = '<div class="flex-spacer"></div>';
        $headerContent = array();
        if ( $returnLinkUrl ) {
            $headerContent[] = $this->view->formatUtil()->getReturnLink( $returnLinkUrl, $returnLinkTitle, $returnLinkTransitionType );
        } else {
            $headerContent[] = $flexSpacer;
        }
        $headerContent[] = '<'.$titleTag.'>'.$title.'</'.$titleTag.'>';
        $headerContent[] = $flexSpacer;

        return $headerContent;
    }

    /**
     * get the markup for a "basic-module" module
     *
     * @param array $config
     * @return string
     */
    public function getBasicModule( $config = array() )
    {
        $configObj = new Sly_DataObject( $config );
        $headerContent = $configObj->getHeaderContent( '' );
        $bodyContent = $configObj->getBodyContent( '' );
        $classPrefixes = $configObj->getClassPrefixes( array() );
        $attributes = $configObj->getAttributes( array() );

        return  $this->getModule(
            array(
                'header' => array(
                    'content' => '
                        <div class="'.join( ' ', $this->getPrefixedClasses( 'hd-content', $classPrefixes ) ).'">
                            '.$headerContent.'
                        </div>
                    ',
                    'attributes' => array(
                        'class' => 'edger-reset'
                    )
                ),
                'body' => array(
                    'content' => '
                        <div class="'.join( ' ', $this->getPrefixedClasses( 'bd-content', $classPrefixes ) ).'">
                            '.$bodyContent.'
                        </div>
                    '
                ),
                'attributes' => $attributes,
                'classPrefixes' => $classPrefixes
            )
        );
    }

    /**
     * get the markup for a Login module
     *
     * @param array $config
     * @return string
     */
    public function getLoginModule( $config = array() )
    {
        $html = '';
        $configObj = new Sly_DataObject( $config );

        $classPrefixes = $configObj->getClassPrefixes( array( 'content-module' ) );

        $delimiter = $configObj->getDelimiter( '__' );


        $classNames = $this->getPrefixedClasses( '', $classPrefixes );


        $header = $this->getSection( $configObj->getHeader( array() ), $classPrefixes, 'hd', $delimiter );
        $body = $this->getSection( $configObj->getBody( array() ), $classPrefixes, 'bd', $delimiter );
        $footer = $this->getSection( $configObj->getFooter( array() ), $classPrefixes, 'ft', $delimiter );

        $attributes = $configObj->getAttributes( array() );
        $attributes = $this->view->formatUtil()->addItemToAttributes( $attributes, 'class', join( ' ', $classNames ) );

        $html .= '

            <div '.$this->view->htmlAttributes( $attributes ).'>
                <div class="login-info">
                    <div class="svgicon--maverick-m-thin"></div>
                </div>
                <div class="login-content">
                    <div class="login-content-container">
                        '.$header.'
                        '.$body.'
                        '.$footer.'
                    </div>
                </div>
            </div>
        ';

        return $html;
    }


    /**
     * get the markup for an "login-module" module
     *
     * @param array $config
     * @return string
     */
    public function getBasicLoginModule( $config = array() )
    {
        $configObj = new Sly_DataObject( $config );
        $headerContent = $configObj->getHeaderContent( '' );
        $bodyContent = $configObj->getBodyContent( '' );
        $classPrefixes = $configObj->getClassPrefixes( array() );
        $attributes = $configObj->getAttributes( array() );


        return  $this->getLoginModule(
            array(
                'header' => array(
                    'content' => '
                        <div class="'.join( ' ', $this->getPrefixedClasses( 'hd-content', $classPrefixes ) ).'">
                            '.$headerContent.'
                        </div>
                    ',
                    'attributes' => array(

                    )
                ),
                'body' => array(
                    'content' => '
                        <div class="'.join( ' ', $this->getPrefixedClasses( 'bd-content', $classPrefixes ) ).'">
                            '.$bodyContent.'
                        </div>
                    '
                ),
                'attributes' => $attributes,
                'classPrefixes' => $classPrefixes
            )
        );
    }

    /**
     * get the markup for a Coppa module
     *
     * @param array $config
     * @return string
     */
    public function getCoppaModule( $config = array() )
    {
        $html = '';
        $configObj = new Sly_DataObject( $config );

        $classPrefixes = $configObj->getClassPrefixes( array( 'content-module' ) );

        $delimiter = $configObj->getDelimiter( '__' );


        $classNames = $this->getPrefixedClasses( '', $classPrefixes );


        $header = $this->getSection( $configObj->getHeader( array() ), $classPrefixes, 'hd', $delimiter );
        $body = $this->getSection( $configObj->getBody( array() ), $classPrefixes, 'bd', $delimiter );
        $footer = $this->getSection( $configObj->getFooter( array() ), $classPrefixes, 'ft', $delimiter );

        $attributes = $configObj->getAttributes( array() );
        $attributes = $this->view->formatUtil()->addItemToAttributes( $attributes, 'class', join( ' ', $classNames ) );

        $html .= '

            <div '.$this->view->htmlAttributes( $attributes ).'>
                <div class="coppa-module-container">
                    <div class="coppa-info">
                        <div class="svgicon--maverick-m-thin"></div>
                        <div class="info-text">'.$footer.'</div>
                    </div>
                    <div class="coppa-content">
                        <div class="coppa-content-container">
                            '.$header.'
                            '.$body.'
                        </div>
                    </div>
                    <div class="coppa-info-mobile">
                        <div class="svgicon--maverick-m-thin"></div>
                        <div class="info-text">'.$footer.'</div>
                    </div>
                </div>
            </div>
        ';

        return $html;
    }


    /**
     * get the markup for an "coppa-module" module
     *
     * @param array $config
     * @return string
     */
    public function getBasicCoppaModule( $config = array() )
    {
        $configObj = new Sly_DataObject( $config );
        $headerContent = $configObj->getHeaderContent( '' );
        $bodyContent = $configObj->getBodyContent( '' );
        $footerContent = $configObj->getFooterContent( '' );
        $classPrefixes = $configObj->getClassPrefixes( array() );
        $attributes = $configObj->getAttributes( array() );

        return  $this->getCoppaModule(
            array(
                'header' => array(
                    'content' => '
                        <div class="'.join( ' ', $this->getPrefixedClasses( 'hd-content', $classPrefixes ) ).'">
                            '.$headerContent.'
                        </div>
                    ',
                    'attributes' => array(

                    )
                ),
                'body' => array(
                    'content' => '
                        <div class="'.join( ' ', $this->getPrefixedClasses( 'bd-content', $classPrefixes ) ).'">
                            '.$bodyContent.'
                        </div>
                    '
                ),
                'footer' => array(
                    'content' => '
                        <div class="'.join( ' ', $this->getPrefixedClasses( 'ft-content', $classPrefixes ) ).'">
                            '.$footerContent.'
                        </div>
                    '
                ),
                'attributes' => $attributes,
                'classPrefixes' => $classPrefixes
            )
        );
    }

    /**
     * get the markup for a "mini-module" module
     *
     * @param array $config
     * @return string
     */
    public function getMiniModule( $config = array() )
    {
        $configObj = new Sly_DataObject( $config );
        $headerContent = $configObj->getHeaderContent( '' );
        $bodyContent = $configObj->getBodyContent( '' );
        $classPrefixes = $configObj->getClassPrefixes( array() );
        $attributes = $configObj->getAttributes( array() );

        return  $this->getModule(
            array(
                'header' => array(
                    'content' => '
                        <div class="'.join( ' ', $this->getPrefixedClasses( 'hd-content', $classPrefixes ) ).'">
                            '.$headerContent.'
                        </div>
                    '
                ),
                'body' => array(
                    'content' => '
                        <div class="'.join( ' ', $this->getPrefixedClasses( 'bd-content', $classPrefixes ) ).'">
                            '.$bodyContent.'
                        </div>
                    '
                ),
                'attributes' => $attributes,
                'classPrefixes' => $classPrefixes
            )
        );
    }

    public function getTitleBar( $config = array() )
    {
        $configObj = new Sly_DataObject( $config );
        $title = $configObj->getTitle();
        $titleLink = $configObj->getTitleLink();
        $titleTag = $configObj->getTitleTag( 'h4' );
        $moreTitle = $configObj->getMoreTitle();
        $moreTitleLink = $configObj->getMoreTitleLink();
        $classPrefixes = $configObj->getClassPrefixes( array() );

        $html[] = '';
        if ( $title ) {
            $html[] = '
                <'.$titleTag.' class="'.join( ' ', $this->getPrefixedClasses( 'title-bar-title', $classPrefixes ) ).' title-bar-title">
                    '.( $titleLink ? '<a href="'.$titleLink.'">'.$title.'</a>' : $title ).'
                </'.$titleTag.'>
            ';
        }

        if ( $moreTitle ) {
            $html[] = '
                <div class="'.join( ' ', $this->getPrefixedClasses( 'title-bar-more', $classPrefixes ) ).' title-bar-more">
                    '.( $moreTitleLink ? '<a href="'.$moreTitleLink.'">'.$moreTitle.'</a>' : $moreTitle ).'
                </div>
            ';
        }

        return '
            <div class="'.join( ' ', $this->getPrefixedClasses( 'title-bar', $classPrefixes ) ).' title-bar">
                '.join( '', $html ).'
            </div>
        ';

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
