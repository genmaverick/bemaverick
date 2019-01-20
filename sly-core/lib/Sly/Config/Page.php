<?php
/**
 * Sly_FileFinder
 */
require_once( SLY_ROOT_DIR . '/lib/Sly/FileFinder.php' );
require_once( SLY_ROOT_DIR . '/lib/Sly/Grid.php' );

/**
 * Class for configuration of a page
 *
 * @category Sly
 * @package Sly_Config
 */
class Sly_Config_Page
{

    /**
     * @var array
     * @access protected
     */
    protected $_data;

    /**
     * @var integer
     * @access protected
     */
    protected $_lastModifiedTimestamp;

    protected $_grids;

    public function __construct($page)
    {
        if ( empty( $page ) ) {
            throw new Zend_Exception( 'Sly_Config_Page::__construct - page is not set' );
        }

        // get the pageDirs
        $pageDirs = Zend_Registry::get( 'systemConfig' )->getPageDirs();

        // load the default xml file
        $defaultConfigFile = Sly_FileFinder::findFile( 'default.xml', $pageDirs );
        $defaultConfig = simplexml_load_file( $defaultConfigFile );

        // load the page xml file
        $pageConfigFile = Sly_FileFinder::findFile( "$page.xml", $pageDirs );

        if ( ! $pageConfigFile ) {
            error_log( "Sly_Config_Page::__construct - could not find xml file: $page.xml" );
            $pageConfigFile = Sly_FileFinder::findFile( 'notfound.xml', $pageDirs );
        }

        $pageConfig = simplexml_load_file( $pageConfigFile );

        // set the modified timestamp
        $this->_lastModifiedTimestamp = filemtime( $defaultConfigFile );

        $this->_data = array();
        $this->_grids = array();

        // set name, template, layout, description, keywords
        $tags = array( 'name', 'template', 'templateAjax', 'layout', 'baseTarget', 'description', 'keywords', 'twitterText', 'gridId' );
        foreach( $tags as $tag ) {
            if ( isset( $pageConfig->$tag ) ) {
                $this->_data[$tag] = (string) $pageConfig->$tag;
            }
            else {
                $this->_data[$tag] = (string) $defaultConfig->$tag;
            }
        }

        // set the title
        $tags = array( 'usePrefix', 'printHeading', 'headingTag', 'headingText',
                       'prefixDelimiter', 'prefix', 'text', 'hasHistory' );

        foreach( $tags as $tag ) {
            if ( isset( $pageConfig->title->$tag ) ) {
                $this->_data['title'][$tag] =
                    (string) $pageConfig->title->$tag;
            }
            else {
                $this->_data['title'][$tag] =
                    (string) $defaultConfig->title->$tag;
            }
        }

        //set page type
        $tags = array( 'type', 'subType' );

        foreach( $tags as $tag ) {
            if ( isset( $pageConfig->$tag ) ) {
                $this->_data[$tag] =
                    (string) $pageConfig->$tag;
            } else {
                $this->_data[$tag] = '';
            }
        }


        // set the nav
        $tags = array( 'primary', 'secondary', 'tertiary', 'quaternary' );

        foreach( $tags as $tag ) {
            if ( isset( $pageConfig->nav->$tag ) ) {
                $this->_data['nav'][$tag] =
                    (string) $pageConfig->nav->$tag;
            }
            else {
                $this->_data['nav'][$tag] =
                    (string) $defaultConfig->nav->$tag;
            }
        }

        // set the form usage
        if ( isset( $pageConfig->form->use ) ) {
            $this->_data['form']['use'] =
                (string) $pageConfig->form->use;
        }
        else {
            $this->_data['form']['use'] =
                (string) $defaultConfig->form->use;
        }

        // set the form attributes
        if ( $this->_data['form']['use'] == 'true' ) {

            $tags = array( 'action', 'method', 'id', 'name' );

            foreach( $tags as $tag ) {
                if ( isset( $pageConfig->form->attributes->$tag ) ) {
                    $this->_data['form']['attributes'][$tag] =
                        (string) $pageConfig->form->attributes->$tag;
                }
                else {
                    $this->_data['form']['attributes'][$tag] =
                        (string) $defaultConfig->form->attributes->$tag;
                }
            }
        }
        else {
            $this->_data['form']['attributes'] = array();
        }

        // set the includes
        $tags = array( 'css', 'cssDefault', 'cssPrint', 'cssMobile', 'cssCritical', 'js', 'jsDefault', 'meta', 'header', 'subHeader', 'hero', 'footer', 'postFooter', 'pageContent', 'pageContentFullScreen', 'prePrimary', 'primary', 'secondary', 'tertiary', 'grids', 'rail' );

        foreach( $tags as $tag ) {

            /*
             * Segregate grids processing since its so
             * different
             */
            if ( $tag == 'grids' ) {
                $item = null;
                if ( isset( $pageConfig->includes->$tag) ) {
                    $item = $pageConfig->includes->$tag;
                }
                else if (isset( $defaultConfig->includes->$tag) ) {
                    $item = $defaultConfig->includes->$tag;
                }
                if ($item) {
                    $this->processGrids($defaultConfig, $pageConfig, $item);
                }
                continue;
            }

            $files = array();
            $moduleNames = array();
            if ( isset( $pageConfig->includes->$tag ) ) {
                $item = $pageConfig->includes->$tag;
                if ( isset( $item['append'] ) && $item['append'] == 'true' && isset($defaultConfig->includes->$tag ) ) {
                    foreach( $defaultConfig->includes->$tag->file as $file ) {
                        $files[] = (string) $file;

                        if ( isset( $file['moduleNames'] ) ) {
                            $moduleNames = array_merge( $moduleNames, explode( ',', (string) $file['moduleNames'] ) );
                        }
                    }
                }
                foreach( $pageConfig->includes->$tag->file as $file ) {
                    $files[] = (string) $file;

                    if ( isset( $file['moduleNames'] ) ) {
                        $moduleNames = array_merge( $moduleNames, explode( ',', (string) $file['moduleNames'] ) );
                    }
                }
            }
            else {
                if ( isset( $defaultConfig->includes->$tag ) ) {
                    foreach( $defaultConfig->includes->$tag->file as $file ) {
                        $files[] = (string) $file;

                        if ( isset( $file['moduleNames'] ) ) {
                            $moduleNames = array_merge( $moduleNames, explode( ',', (string) $file['moduleNames'] ) );
                        }
                    }
                }
            }

            $this->_data['includes'][$tag]['files'] = $files;
            $this->_data['includes'][$tag]['moduleNames'] = $moduleNames;
        }

        // set the init js commands
        $commands = array();
        if ( isset( $pageConfig->jsInit ) ) {
            if ( isset( $pageConfig->jsInit['append'] ) &&
                 $pageConfig->jsInit['append'] == 'true' ) {
                foreach( $defaultConfig->jsInit->command as $command ) {
                    $commands[] = (string) $command;
                }
            }
            foreach( $pageConfig->jsInit->command as $command ) {
                $commands[] = (string) $command;
            }
        }
        else {
            foreach( $defaultConfig->jsInit->command as $command ) {
                $commands[] = (string) $command;
            }
        }

        $this->_data['jsInit']['commands'] = $commands;

        // set the css styles
        $cssStyles = array();
        if ( isset( $defaultConfig->cssStyles ) ) {
            foreach( $defaultConfig->cssStyles->style as $style ) {
                $name = (string) $style->name;
                $value = (string) $style->value;

                $cssStyles[$name] = $value;
            }
        }

        $this->_data['cssStyles'] = $cssStyles;

        // set the modules
        if ( isset( $pageConfig->modules ) ) {
            foreach( $pageConfig->modules->module as $module ) {
                $name = (string) $module->name;

                $this->_data['modules'][$name]['file'] = (string) $module->file;

                if ( isset( $module->destinations ) ) {
                    $destinations = array();
                    foreach( $module->destinations->destination as $destination ) {
                        $destinations[] = (string) $destination;
                    }
                    $this->_data['modules'][$name]['destinations'] = $destinations;
                }

                if ( isset( $module->collapse ) ) {
                    $this->_data['modules'][$name]['collapsible'] =
                        (string) $module->collapse->collapsible;
                    $this->_data['modules'][$name]['collapsed'] =
                        (string) $module->collapse->collapsed;
                }

                if ( isset( $module->permissions ) ) {
                    $this->_data['modules'][$name]['permissions']['viewer'] =
                        (string) $module->permissions->viewer;
                    $this->_data['modules'][$name]['permissions']['owner'] =
                        (string) $module->permissions->owner;
                }
            }
        }

        // set the ads
        $ads = array();
        $adObject = null;
        if ( isset($pageConfig->ads) ) {
            $adObject = $pageConfig->ads;
        } else if ( isset($defaultConfig->ads) ) {
            $adObject = $defaultConfig->ads;
        }

        if ( $adObject ) {
            foreach( $adObject->ad as $ad ) {
                $type = (string) $ad->type;
                $id = (string) $ad->id;
                $css = (string) $ad->css;
                $html = (string) $ad->html;
                $file = (string) $ad->file;
                $brand = (string) $ad->brand;
                $slot = (string) $ad->slot;
                $code = (string) $ad->code;
                $tile = (string) $ad->tile;
                $rotation = (string) $ad->rotation;
                $refresh = (string) $ad->refresh;
                $ads[] = array(
                    'type' => $type, 'code' => $code, 'tile' => $tile, 'slot' => $slot, 'rotation' => $rotation,
                    'id' => $id, 'css' => $css, 'html' => $html, 'file' => $file, 'brand' => $brand, 'refresh' => $ad
                );
            }
        }

        $this->_data['ads'] = $ads;


        // set the ad config
        $this->_data['adConfig'] = array();
        if ( isset( $pageConfig->adConfig ) ) {

            $properties = array();
            if ( isset( $pageConfig->adConfig->property ) ) {
                if ( isset( $pageConfig->adConfig['append'] ) &&
                     $pageConfig->adConfig['append'] == 'true' && isset( $defaultConfig->adConfig ) ) {
                    foreach( $defaultConfig->adConfig->property as $property ) {
                        $properties[(string)$property->key] = (string)$property->value;
                    }
                }
                foreach( $pageConfig->adConfig->property as $property ) {
                    $properties[(string)$property->key] = (string) $property->value;
                }
            }
            else if ( isset( $defaultConfig->adConfig ) ) {
                foreach( $defaultConfig->adConfig->property as $property ) {
                    $properties[(string)$property->key] = (string) $property->value;
                }
            }

            $this->_data['adConfig']['properties'] = $properties;
        }
        else if ( isset( $defaultConfig->adConfig ) ) {

            if ( isset( $defaultConfig->adConfig->property ) ) {
                $sections = array();
                foreach( $defaultConfig->adConfig->property as $property ) {
                    $properties[(string)$property->key] = (string)$property->value;
                }
                $this->_data['adConfig']['properties'] = $properties;
            }
        }

        // set the analytics config
        $this->_data['analyticsConfig'] = array();
        if ( isset( $pageConfig->analyticsConfig ) ) {

            $properties = array();
            if ( isset( $pageConfig->analyticsConfig->property ) ) {
                if ( isset( $pageConfig->analyticsConfig['append'] ) &&
                     $pageConfig->analyticsConfig['append'] == 'true' && isset( $defaultConfig->analyticsConfig ) ) {
                    foreach( $defaultConfig->analyticsConfig->property as $property ) {
                        $properties[(string)$property->key] = (string)$property->value;
                    }
                }
                foreach( $pageConfig->analyticsConfig->property as $property ) {
                    $properties[(string)$property->key] = (string) $property->value;
                }
            }
            else if ( isset( $defaultConfig->analyticsConfig ) ) {
                foreach( $defaultConfig->analyticsConfig->property as $property ) {
                    $properties[(string)$property->key] = (string) $property->value;
                }
            }

            $this->_data['analyticsConfig']['properties'] = $properties;
        }
        else if ( isset( $defaultConfig->analyticsConfig ) ) {

            if ( isset( $defaultConfig->analyticsConfig->property ) ) {
                $sections = array();
                foreach( $defaultConfig->analyticsConfig->property as $property ) {
                    $properties[(string)$property->key] = (string)$property->value;
                }
                $this->_data['analyticsConfig']['properties'] = $properties;
            }
        }

        // set the page tracking
        $this->_data['pageTracking'] = array();
        if ( isset( $pageConfig->pageTracking ) ) {
            if ( isset( $pageConfig->pageTracking->googleAnalytics ) ) {
                $this->_data['pageTracking']['googleAnalytics']['ua'] = $pageConfig->pageTracking->googleAnalytics->ua;
            }
            $sections = array();
            if ( isset( $pageConfig->pageTracking->omniture ) ) {
                if ( isset( $pageConfig->pageTracking['append'] ) &&
                     $pageConfig->pageTracking['append'] == 'true' ) {
                    foreach( $defaultConfig->pageTracking->omniture->section as $section ) {
                        $sections[] = (string) $section;
                    }
                }
                foreach( $pageConfig->pageTracking->omniture->section as $section ) {
                    $sections[] = (string) $section;
                }
            }
            else if ( isset( $defaultConfig->pageTracking ) ) {
                foreach( $defaultConfig->pageTracking->omniture->section as $section ) {
                    $sections[] = (string) $section;
                }
            }

            $this->_data['pageTracking']['omniture']['sections'] = $sections;


        }
        else if ( isset( $defaultConfig->pageTracking ) ) {
            if ( isset( $defaultConfig->pageTracking->googleAnalytics ) ) {
                $this->_data['pageTracking']['googleAnalytics']['ua'] = $defaultConfig->pageTracking->googleAnalytics->ua;
            }
            if ( isset( $defaultConfig->pageTracking->omniture ) ) {
                $sections = array();
                foreach( $defaultConfig->pageTracking->omniture->section as $section ) {
                    $sections[] = (string) $section;
                }
                $this->_data['pageTracking']['omniture']['sections'] = $sections;
            }
        }

    }

    public function getGrid()
    {
        return $this->getGridById($this->getGridId());
    }

    protected function processGrids( $defaultConfig, $pageConfig, $grids )
    {
        foreach ( $grids->grid as $grid ) {
            if ( !isset($grid['id']) ) {
                //error_log(get_class($this) . ": Grid specified without ID. Skipping.");
            }
            $gridId = strval($grid['id']);
            $gridType = ((isset($grid['type'])) ? strval($grid['type']) : 'fixed'); // Default to fixed

            $oGrid = new Sly_Grid($gridId, $gridType);
            foreach ( $grid->row as $gridRow ) {
                $oGrid->addRow($this->processGridRow($defaultConfig, $pageConfig, $gridRow));
            }
            $this->addGrid($oGrid);
        }
    }

    protected function processGridRow( $defaultConfig, $pageConfig, $row )
    {
        $rowData = array();
        foreach ( $row as $gridUnit ) {
            $rowData[] = $this->processGridUnit($defaultConfig, $pageConfig, $gridUnit);
        }
        return new Sly_GridRow($rowData);
    }

    protected function processGridUnit( $defaultConfig, $pageConfig, $unit )
    {
        if ( !isset($unit['id']) ) {
            //error_log(get_class($this) . ": Unit specified without ID. Fine, but won't look elsewhere for files to include.");
        }
        $unitId    = ((isset($unit['id'])) ? strval($unit['id']) : false);
        $unitWidth = ((isset($unit['width'])) ? strval($unit['width']) : null);
        $unitClass = ((isset($unit['class'])) ? strval($unit['class']) : null);
        $unitContentIsWrapped = ((isset($unit['wrapContent'])) ? (strval($unit['wrapContent']) == 'true') : false);

        $attributes = array();
        if ( $unitClass ) {
            $attributes = array( 'class' => $unitClass );
        }

        $oUnit = new Sly_GridUnit($unitId, $unitWidth, null, '', $attributes );
        $oUnit->setIsContentWrapped($unitContentIsWrapped);

        $defaultFiles = array();
        foreach ($unit->file as $unitFile) {
            $defaultFiles[] = (string) $unitFile;
        }

        $appendAdditionalFiles = true;
        $defaultConfigFiles = array();
        $additionalFiles = array();
        if ($oUnit->hasId()) {
            $unitTag = $oUnit->getUnitIdTag();
            // Look in default config
            if ( isset( $defaultConfig->includes->$unitTag ) ) {
                $item = $defaultConfig->includes->$unitTag;
                foreach( $item->file as $file ) {
                    $defaultConfigFiles[] = (string) $file;
                }
            }

            // Look for overrides
            if ( isset( $pageConfig->includes->$unitTag ) ) {
                $item = $pageConfig->includes->$unitTag;
                $appendAdditionalFiles = (!isset( $item['append'] ) ||
                                          ($item['append'] == 'true'));
                foreach( $item->file as $file ) {
                    $additionalFiles[] = (string) $file;
                }
            }
        }

        $files = $additionalFiles;

        if ($appendAdditionalFiles) {
            $files = array_merge($defaultFiles, $defaultConfigFiles, $additionalFiles);
        }

        $oUnit->setFiles($files);

        return $oUnit;
    }

    protected function addGrid( $oGrid )
    {
        $gridId = $oGrid->getId();
        if ( array_key_exists($gridId, $this->_grids) ) {
            // Warn but proceed, I guess.
            //error_log(get_class($this) . ": Grid with ID \"" . $gridId . "\" already processed. Overriding.");
        }
        $this->_grids[$gridId] = $oGrid;
    }

    public function getGridById( $gridId )
    {
        if ( array_key_exists( $gridId, $this->_grids ) ) {
            return $this->_grids[$gridId];
        }
        //error_log(get_class($this) . ": Grid with ID \"" . $gridId . "\" not found. Found grid IDs \"" . implode(array_keys($this->_grids), "\", \"") . "\"");
        return null;
    }

    function getLastModifiedTimestamp()
    {
        return $this->_lastModifiedTimestamp;
    }

    function useTitlePrefix()
    {
        if ( $this->_data['title']['usePrefix'] == 'true' ) {
            return true;
        }
        return false;
    }

    function getTitlePrefix()
    {
        return $this->_data['title']['prefix'];
    }

    function hasHistory()
    {
        return $this->_data['title']['hasHistory'];
    }



    function getTitlePrefixDelimiter()
    {
        return $this->_data['title']['prefixDelimiter'];
    }

    function getTitle()
    {
        return $this->_data['title']['text'];
    }

    function setTitle( $title )
    {
        $this->_data['title']['text'] = $title;
    }

    function useTitleHeading()
    {
        if ( $this->_data['title']['printHeading'] == 'true' ) {
            return true;
        }
        return false;
    }

    function getTitleHeadingTag()
    {
        return $this->_data['title']['headingTag'];
    }

    function getTitleHeadingText()
    {
	if (!empty($this->_data['title']['headingText'])){
        	return $this->_data['title']['headingText'];
	}
	return false;
    }

    function getDescription()
    {
        return $this->_data['description'];
    }

    function getKeywords()
    {
        return $this->_data['keywords'];
    }

    function getTwitterText()
    {
        return $this->_data['twitterText'];
    }

    function getTemplate()
    {
        return $this->_data['template'];
    }

    function getTemplateAjax()
    {
        return $this->_data['templateAjax'];
    }

    function getName()
    {
        return $this->_data['name'];
    }

    function getType()
    {
        return $this->_data['type'];
    }
    function getSubType()
    {
        return $this->_data['subType'];
    }

    function getPrimaryNav()
    {
        return $this->_data['nav']['primary'];
    }

    function setPrimaryNav( $primaryNav )
    {
        $this->_data['nav']['primary'] = $primaryNav;
    }

    function getSecondaryNav()
    {
        return $this->_data['nav']['secondary'];
    }

    function setSecondaryNav( $secondaryNav )
    {
        $this->_data['nav']['secondary'] = $secondaryNav;
    }

    function getTertiaryNav()
    {
        return $this->_data['nav']['tertiary'];
    }

    function getQuaternaryNav()
    {
        return $this->_data['nav']['quaternary'];
    }

    function getLayout()
    {
        return $this->_data['layout'];
    }

    function getGridId()
    {
        return $this->_data['gridId'];
    }

    function getBaseTarget()
    {
        return (array_key_exists('baseTarget', $this->_data)) ? $this->_data['baseTarget'] : false;
    }


    function hasMetaFiles()
    {
        if ( count( $this->getMetaFiles() ) > 0 ) {
            return true;
        }
        return false;
    }

    function getMetaFiles()
    {
        return $this->_data['includes']['meta']['files'];
    }

    function hasCssFiles()
    {
        if ( count( $this->getCssFiles() ) > 0 ) {
            return true;
        }
        return false;
    }

    function getCssFiles()
    {
        return $this->_data['includes']['css']['files'];
    }


    function hasCssPrintFiles()
    {
        if ( count( $this->getCssPrintFiles() ) > 0 ) {
            return true;
        }
        return false;
    }

    function getCssPrintFiles()
    {
        return $this->_data['includes']['cssPrint']['files'];
    }

    function hasCssCriticalFiles()
    {
        if ( count( $this->getCssCriticalFiles() ) > 0 ) {
            return true;
        }
        return false;
    }

    function getCssCriticalFiles()
    {
        return $this->_data['includes']['cssCritical']['files'];
    }

    function hasCssDefaultFiles()
    {
        if ( count( $this->getCssDefaultFiles() ) > 0 ) {
            return true;
        }
        return false;
    }

    function getCssDefaultFiles()
    {
        return $this->_data['includes']['cssDefault']['files'];
    }

    function hasCssMobileFiles()
    {
        if ( count( $this->getCssMobileFiles() ) > 0 ) {
            return true;
        }
        return false;
    }

    function getCssMobileFiles()
    {
        return $this->_data['includes']['cssMobile']['files'];
    }

    function hasJsDefaultFiles()
    {
        if ( count( $this->getJsDefaultFiles() ) > 0 ) {
            return true;
        }
        return false;
    }

    function getJsDefaultFiles()
    {
        return $this->_data['includes']['jsDefault']['files'];
    }

    function getJsDefaultModuleNames()
    {
        return array_unique( $this->_data['includes']['jsDefault']['moduleNames'] );
    }

    function hasJsFiles()
    {
        if ( count( $this->getJsFiles() ) > 0 ) {
            return true;
        }
        return false;
    }

    function getJsFiles()
    {
        return $this->_data['includes']['js']['files'];
    }

    function getJsModulesNames()
    {
        return array_unique( $this->_data['includes']['js']['moduleNames'] );
    }

    function hasHeaderFiles()
    {
        if ( count( $this->getHeaderFiles() ) > 0 ) {
            return true;
        }
        return false;
    }

    function getHeaderFiles()
    {
        return $this->_data['includes']['header']['files'];
    }

    function hasSubHeaderFiles()
    {
        if ( count( $this->getSubHeaderFiles() ) > 0 ) {
            return true;
        }
        return false;
    }

    function getSubHeaderFiles()
    {
        return $this->_data['includes']['subHeader']['files'];
    }

    function hasHeroFiles()
    {
        if ( count( $this->getHeroFiles() ) > 0 ) {
            return true;
        }
        return false;
    }

    function getHeroFiles()
    {
        return $this->_data['includes']['hero']['files'];
    }

    function hasPageContentFiles()
    {
        if ( count( $this->getPageContentFiles() ) > 0 ) {
            return true;
        }
        return false;
    }

    function getPageContentFiles()
    {
        return $this->_data['includes']['pageContent']['files'];
    }

    function hasPageContentFullScreenFiles()
    {
        if ( count( $this->getPageContentFullScreenFiles() ) > 0 ) {
            return true;
        }
        return false;
    }

    function getPageContentFullScreenFiles()
    {
        return $this->_data['includes']['pageContentFullScreen']['files'];
    }



    function hasPrePrimaryFiles()
    {
        if ( count( $this->getPrePrimaryFiles() ) > 0 ) {
            return true;
        }
        return false;
    }

    function getPrePrimaryFiles()
    {
        return $this->_data['includes']['prePrimary']['files'];
    }

    function hasPrimaryFiles()
    {
        if ( count( $this->getPrimaryFiles() ) > 0 ) {
            return true;
        }
        return false;
    }

    function getPrimaryFiles()
    {
        return $this->_data['includes']['primary']['files'];
    }

    function setPrimaryFiles( $primaryFiles )
    {
        $this->_data['includes']['primary']['files'] = $primaryFiles;
    }

    function hasRailFiles()
    {
        if ( count( $this->getRailFiles() ) > 0 ) {
            return true;
        }
        return false;
    }

    function getRailFiles()
    {
        return $this->_data['includes']['rail']['files'];
    }

    function setRailFiles( $railFiles )
    {
        $this->_data['includes']['rail']['files'] = $railFiles;
    }

    function hasSecondaryFiles()
    {
        if ( count( $this->getSecondaryFiles() ) > 0 ) {
            return true;
        }
        return false;
    }

    function getSecondaryFiles()
    {
        return $this->_data['includes']['secondary']['files'];
    }

    function setSecondaryFiles( $secondaryFiles )
    {
        $this->_data['includes']['secondary']['files'] = $secondaryFiles;
    }

    function hasTertiaryFiles()
    {
        if ( count( $this->getTertiaryFiles() ) > 0 ) {
            return true;
        }
        return false;
    }

    function getTertiaryFiles()
    {
        return $this->_data['includes']['tertiary']['files'];
    }

    function setTertiaryFiles( $tertiaryFiles )
    {
        $this->_data['includes']['tertiary']['files'] = $tertiaryFiles;
    }

    function hasFooterFiles()
    {
        if ( count( $this->getFooterFiles() ) > 0 ) {
            return true;
        }
        return false;
    }

    function getFooterFiles()
    {
        return $this->_data['includes']['footer']['files'];
    }

    function hasPostFooterFiles()
    {
        if ( count( $this->getPostFooterFiles() ) > 0 ) {
            return true;
        }
        return false;
    }

    function getPostFooterFiles()
    {
        return $this->_data['includes']['postFooter']['files'];
    }


    function hasAds()
    {
        if ( count( $this->getAds() ) > 0 ) {
            return true;
        }
        return false;
    }

    function getAds()
    {
        return $this->_data['ads'];
    }

    function getPageTracking()
    {
        return $this->_data['pageTracking'];
    }

    function getAdConfig()
    {
        return $this->_data['adConfig'];
    }

    function getAnalyticsConfig()
    {
        return $this->_data['analyticsConfig'];
    }

    function useGlobalForm()
    {
        if ( $this->_data['form']['use'] == 'true' ) {
            return true;
        }
        return false;
    }

    function getFormAttributes()
    {
        return $this->_data['form']['attributes'];
    }

    function getJsInitCommands()
    {
        return $this->_data['jsInit']['commands'];
    }

    function getCssStyle( $name )
    {
        return $this->_data['cssStyles'][$name];
    }

    function getModules()
    {
        if ( isset( $this->_data['modules'] ) ) {
            return $this->_data['modules'];
        }
        return array();
    }

    function isModuleDefined( $moduleName )
    {
        if ( isset( $this->_data['modules'][$moduleName] ) ) {
            return true;
        }
        return false;
    }

    function isModuleCollapsible( $moduleName )
    {
        if ( ! $this->isModuleDefined( $moduleName ) ) {
            return false;
        }

        if ( $this->_data['modules'][$moduleName]['collapsible'] == 'true' ) {
            return true;
        }
        return false;
    }

    function isModuleCollapsed( $moduleName )
    {
        if ( ! $this->isModuleDefined( $moduleName ) ) {
            return false;
        }

        if ( $this->_data['modules'][$moduleName]['collapsed'] == 'true' ) {
            return true;
        }
        return false;
    }

    function setModuleCollapsed( $moduleName, $isCollapsed )
    {
        if ( ! $this->isModuleDefined( $moduleName ) ) {
            return false;
        }

        $this->_data['modules'][$moduleName]['collapsed'] = $isCollapsed;
    }

    function getModuleDestinations( $moduleName )
    {
        if ( ! $this->isModuleDefined( $moduleName ) ) {
            return false;
        }

        return $this->_data['modules'][$moduleName]['destinations'];
    }

    function isModuleEditableByOwner( $moduleName )
    {
        if ( ! $this->isModuleDefined( $moduleName ) ) {
            return false;
        }

        if ( $this->_data['modules'][$moduleName]['permissions']['owner'] == 'true' ) {
            return true;
        }
        return false;
    }

    function isModuleEditableByViewer( $moduleName )
    {
        if ( ! $this->isModuleDefined( $moduleName ) ) {
            return false;
        }

        if ( $this->_data['modules'][$moduleName]['permissions']['viewer'] == 'true' ) {
            return true;
        }
        return false;
    }

    function getModuleFile( $moduleName )
    {
        if ( ! $this->isModuleDefined( $moduleName ) ) {
            return false;
        }

        return $this->_data['modules'][$moduleName]['file'];
    }

    function isIndexable()
    {
        $systemConfig = Zend_Registry::get( 'systemConfig' );

        if ( $systemConfig->getHttpHost( true ) == $systemConfig->getHttpHost( false ) ) {
            return true;
        }

        return false;
    }

    function getSocialMediaButtonData( $overrideData = array() )
    {
        $systemConfig = Zend_Registry::get( 'systemConfig' );

        $canonicalUrl = $systemConfig->getCurrentUrl( false );

        // remove everything after the ?
        $canonicalUrl = preg_replace( '/\?.*/', '', $canonicalUrl );

        // set the twitter params
        $pageTitle = $this->getTitle();

        $twitterText = $this->getTwitterText();
        $twitterText = str_replace( ':pageTitle', $pageTitle, $twitterText );

        // set the data
        $data = array(
            'facebook' => array(
                'url' => $canonicalUrl,
            ),
            'twitter' => array(
                'url' => $canonicalUrl,
                'canonicalUrl' => $canonicalUrl,
                'text' => $twitterText,
            ),
            'gPlus' => array(
                'url' => $canonicalUrl,
            ),
            'linkedIn' => array(
                'url' => $canonicalUrl,
            ),
            'weibo' => array(
                'url' => $canonicalUrl,
            ),
        );

        // make the overrides
        foreach( $overrideData as $platform => $info ) {
            foreach( $info as $key => $value ) {
                $data[$platform][$key] = $value;
            }
        }

        return $data;
    }
}
