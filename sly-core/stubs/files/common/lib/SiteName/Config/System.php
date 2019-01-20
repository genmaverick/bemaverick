<?php

require_once( SLY_ROOT_DIR . '/lib/Sly/Config/System.php' );

class __SLY_CLASS_PREFIX___Config_System extends Sly_Config_System
{

    public function getFontDirs()
    {
        $dirs = array(
            SYSTEM_ROOT_DIR . '/fonts',
            __SLY_REPOSITORY_UPPERCASE_NAME___COMMON_ROOT_DIR  . '/fonts',
            SLY_ROOT_DIR    . '/fonts',
        );

        return $dirs;
    }

    public function getCSSDirs()
    {
        $dirs = array(
            SYSTEM_ROOT_DIR . '/css/compiled',
            SYSTEM_ROOT_DIR . '/css',
            __SLY_REPOSITORY_UPPERCASE_NAME___COMMON_ROOT_DIR  . '/css',
            SLY_ROOT_DIR    . '/css',
            TWITTER_ROOT_DIR . '/bootstrap/'.SYSTEM_TWITTER_BOOTSTRAP_VERSION.'/css',            
        );

        return $dirs;
    }

    public function getImagesDir()
    {
        $dirs = array(
            SYSTEM_ROOT_DIR . '/img',
            __SLY_REPOSITORY_UPPERCASE_NAME___COMMON_ROOT_DIR  . '/img',
            SLY_ROOT_DIR    . '/img',
        );

        return $dirs;
    }

    public function getJSDirs()
    {
        $dirs = array(
            SYSTEM_ROOT_DIR . '/js',
            __SLY_REPOSITORY_UPPERCASE_NAME___COMMON_ROOT_DIR  . '/js',
            SLY_ROOT_DIR    . '/js',
        );

        return $dirs;
    }

    public function getModuleDirs( $site = null )
    {
        // these need to be in reverse order, because of how
        // Zend_View_Abstract::_script is used.

        $dirs = array(
            SLY_ROOT_DIR    . '/modules',
            __SLY_REPOSITORY_UPPERCASE_NAME___COMMON_ROOT_DIR  . '/modules',
            SYSTEM_ROOT_DIR . '/modules',
        );

        return $dirs;
    }

    public function getPageDirs()
    {
        $dirs = array(
            SYSTEM_ROOT_DIR . '/pages',
            __SLY_REPOSITORY_UPPERCASE_NAME___COMMON_ROOT_DIR  . '/pages',
            SLY_ROOT_DIR    . '/pages',
        );

        return $dirs;
    }

    public function getViewHelpers()
    {
        $helpers = array(
            array(
                'path'        => SLY_ROOT_DIR . '/lib/Sly/View/Helper',
                'classPrefix' => 'Sly_View_Helper',
            ),
            array(
                'path'        => __SLY_REPOSITORY_UPPERCASE_NAME___COMMON_ROOT_DIR . '/helpers',
                'classPrefix' => '__SLY_CLASS_PREFIX___View_Helper',
            ),
        );

        return $helpers;
    }
    
}

?>
