<?php

class Sly_Wap
{

    function isMobileBrowser()
    {

        if ( @$_GET['mobile'] == 1 ) {
            return true;
        }

        // if ipad, don't consider mobile
        if ( preg_match( '/ipad/i', strtolower(@$_SERVER['HTTP_USER_AGENT']) ) ) {
            return false;
        }

        if ( preg_match( '/(up.browser|up.link|mmp|symbian|smartphone|midp|wap|phone|mobile|iphone)/i', strtolower(@$_SERVER['HTTP_USER_AGENT']) ) ) {
            return true;
        }

        if ( strpos(strtolower(@$_SERVER['HTTP_ACCEPT']),'application/vnd.wap.xhtml+xml') > 0 ||
             isset($_SERVER['HTTP_X_WAP_PROFILE']) ||
             isset($_SERVER['HTTP_PROFILE']) ) {
            return true;
        }

        $mobile_ua = strtolower(substr(@$_SERVER['HTTP_USER_AGENT'],0,4));
        $mobile_agents = array(
          'w3c ','acs-','alav','alca','amoi','audi','avan','benq','bird','blac',
          'blaz','brew','cell','cldc','cmd-','dang','doco','eric','hipt','inno',
          'ipaq','java','jigs','kddi','keji','leno','lg-c','lg-d','lg-g','lge-',
          'maui','maxo','midp','mits','mmef','mobi','mot-','moto','mwbp','nec-',
          'newt','noki','oper','palm','pana','pant','phil','play','port','prox',
          'qwap','sage','sams','sany','sch-','sec-','send','seri','sgh-','shar',
          'sie-','siem','smal','smar','sony','sph-','symb','t-mo','teli','tim-',
          'tosh','tsm-','upg1','upsi','vk-v','voda','wap-','wapa','wapi','wapp',
          'wapr','webc','winw','winw','xda','xda-');

        if ( in_array( $mobile_ua, $mobile_agents ) ) {
            return true;
        }

        if ( strpos(strtolower(@$_SERVER['ALL_HTTP']),'OperaMini') > 0 ) {
            return true;
        }

        return false;
    }

    function isIPhoneBrowser()
    {
        if ( preg_match( '/iphone/i', strtolower(@$_SERVER['HTTP_USER_AGENT']) ) ) {
            return true;
        }
        
        return false;
    }

    function isIOSBrowser()
    {
        if ( preg_match( '/(ipad|iphone|ipod)/i', strtolower(@$_SERVER['HTTP_USER_AGENT']) ) ) {
            return true;
        }
        
        return false;
    }
    
}

?>
