<?php
require_once( ZEND_ROOT_DIR . '/lib/Zend/Json.php' );
require_once( SLY_ROOT_DIR . '/lib/Sly/Date.php' );

/**
 * Helper for creating html attribute string
 */
class Sly_View_Helper_FormatUtil
{
    /**
     * The view object that created this helper object.
     *
     * possible types:
     * 		name			- group name linked to profile - default
     *
     * @var Zend_View
     */
    public $view;


    public function formatUtil()
    {
        return $this;
    }

    public function getLoginLink( $title = 'Login', $attributes = array() )
    {
        return '<a href="'.$this->view->url('authLogin').'"'. $this->view->htmlAttributes( $attributes ) .'>'. $title .'</a>';
    }

    public function getLogoutLink( $title = 'Logout', $attributes = array() )
    {
        return '<a href="'.$this->view->url('authLogout').'"'. $this->view->htmlAttributes( $attributes ) .'>'. $title .'</a>';
    }


    public function autoLink( $text, $newWindow = false )
    {

        // shawnr - updated this on Nov 15, 2016 and so far it seems to work
        $regex = '/((http|https):\/\/)?([a-z0-9-]+\.)?[a-z0-9-]+(\.[a-z]{2,6}){1,3}(\/[a-z0-9.,_\/~#&=;%+?-]*)?/is';

        $text = preg_replace($regex, " <a target='_blank' href='$0'>$0</a>", $text);
        $text = preg_replace("/href='[^h][^t][^t][^p][^s]?[^:]/", "/href='http:\/\/", $text);

        return $text;


        $target = $newWindow ? ' target="_blank"' : '';

$regex = '{
  \\b
  # Match the leading part (proto://hostname, or just hostname)
  (
    # http://, or https:// leading part
    (https?)://[-\\w]+(\\.\\w[-\\w]*)+
  |
    # or, try to find a hostname with more specific sub-expression
    (?i: [a-z0-9] (?:[-a-z0-9]*[a-z0-9])? \\. )+ # sub domains
    # Now ending .com, etc. For these, require lowercase
    (?-i: com\\b
        | edu\\b
        | biz\\b
        | gov\\b
        | in(?:t|fo)\\b # .int or .info
        | mil\\b
        | net\\b
        | org\\b
        | [a-z][a-z]\\.[a-z][a-z]\\b # two-letter country code
    )
  )

  # Allow an optional port number
  ( : \\d+ )?

  # The rest of the URL is optional, and begins with /
  (
    /
    # The rest are heuristics for what seems to work well
    [^.!,?;"\\\'<>()\[\]\{\}\\s\x7F-\\xFF]*
    (?:
      [.!,?]+ [^.!,?;”\\’<>()\\[\\]\{\\}\\s\\x7F-\\xFF]+
    )*
  )?
}ix';


        //return preg_replace( $regex, '<a '.$target.' href="$0">$0</a>', $text );

        // the below code was not working for this post:
        // 11/11/2016 - this is fixed!
        // https://fantasymovieleague.com/chatter/topiccomments?boardId=leaders&topicId=146201

        preg_match_all( $regex, $text, $matches );

        // we only want to do the urls once though and sorted by largest to smallest
        $urls = array_unique( $matches[0] );
        array_multisort( array_map( 'strlen', $urls ), $urls );
        $urls = array_reverse( $urls );

        foreach( $urls as $url ) {

            // if the url already ends in </a> or is within a tag, then don't convert
            $regex = '%'.$url.'(?![^<]*</a>)%i';

            if ( strpos( $url, '://' ) !== FALSE ) {
                $text = preg_replace( $regex, "<a $target href=\"$url\">$url</a>", $text );
            }
            else {
                $text = preg_replace( $regex, "<a $target href=\"http://$url\">$url</a>", $text );
            }
        }

        return $text;
    }

    public function getEmpty(){
        return '<span>---</span>';
    }

    public function getScroller($id, $listItems =array(), $listAttributes=array()){
        $html = array();
        $html[] = '<div id="'.$id.'Wrap" class="scrollerWrap">';
        $html[] = '<div class="scroller" id="'.$id.'">';
        $html[] = $this->view->linkList($listItems, $listAttributes );
        $html[] = '</div>';
        $html[] = '<span class="scrollLeft">&laquo;</span>           <span class="scrollRight">&raquo;</span>';
        $html[] = '</div>';
        return join('',$html);
    }

    public function getModuleButtonBar($items = array(), $additionalHtml = null, $attributes = array() ){
        $html = array();


        if( !count($items) && !$additionalHtml) {

             return '';
        }

        $attributes = $this->addItemToAttributes( $attributes , 'class', 'subHd' );

        $html[] = '<div '.$this->view->htmlAttributes($attributes).'>';

        if(count($items)){
            $html[] = $this->view->linkList($items);
        }
        $html[] = ' '.$additionalHtml;
        $html[] = '</div>';

        return join('',$html);
    }

    public function getDelimitedItemString( $items , $delimiter = ', ', $getName = true, $deDupe = false ) {
        $xhtml = array();

        foreach( $items as $item ) {
            if ( $getName ) {
                $xhtml[] = $item->getName();
            } else {
                if ( $item != '' ) {
                    $xhtml[] = $item;
                }
            }
        }

        if ( $deDupe ) {
            $xhtml = array_unique($xhtml);
        }

        return join( $delimiter, $xhtml );

    }



    public function addItemToAttributes( $attributes = array(), $key, $value ) {

        if ( isset($attributes[$key])  ) {
            if(is_array($attributes[$key])) {
                $attributes[$key][] = $value;
            } else {
                $attributes[$key] .= ' '.$value;
            }
        } else {
            $attributes[$key] = $value;
        }
        return $attributes;
    }


    public function truncate( $text, $length, $encode = true, $endString = '...' )
    {

        $text = html_entity_decode( $text, ENT_QUOTES, 'UTF-8' );

        if ( strlen($text) > $length ) {

            $text = substr( $text, 0, $length );
            $lastWhitespacePos = strrpos( $text, ' ' );

            // if there is a whitespace, then put the elipses after that
            if ( $lastWhitespacePos ) {
                $text = substr($text, 0, $lastWhitespacePos) . $endString;
            }
            else {
                $text = $text . $endString;
            }
        }

        if ($encode) {
            $text = htmlentities($text, ENT_QUOTES, 'UTF-8');
        }

        return $text;
    }

    public function tokenTruncate( $text, $optimalLength, $endString = '' ) {
        $parts = preg_split('/([\s\n\r]+)/', $text, null, PREG_SPLIT_DELIM_CAPTURE);
        $parts_count = count($parts);

        $length = 0;
        $last_part = 0;
        for (; $last_part < $parts_count; ++$last_part) {
            $length += strlen($parts[$last_part]);
            if ($length > $optimalLength) { break; }
        }
        $newText = trim(implode(array_slice($parts, 0, $last_part)));
        if ( $newText != $text ) {
            $newText .= $endString;
        }
        return $newText;
    }


    public function truncateHTML( $text, $length, $endString = '&hellip;' )
        {
            $i = 0;
            $ignoreTags = array(
               'br' => true,
               'hr' => true,
               'input' => true,
               'img' => true,
               'link' => true,
               'meta' => true
            );
            $usedTags = array();
            preg_match_all( '/<[^>]+>([^<]*)/',
                            $text,
                            $matches,
                            PREG_OFFSET_CAPTURE | PREG_SET_ORDER );
            foreach ($matches as $m) {
                if ( ($m[0][1] - $i) >= $length ) {
                   break;
                }
                $tag = substr(strtok($m[0][0], " \t\n\r\0\x0B>"), 1);
                if ( ($tag[0] != '/') && (!isset($ignoreTags[$tag])) ) {
                   $usedTags[] = $tag;
                } else if ( end($usedTags) == substr($tag, 1) ) {
                   array_pop($usedTags);
                }
                $i += $m[1][1] - $m[0][1];
            }
            $html = substr( $text, 0, $length = min(strlen($text), $length + $i) );
            $html2 = (count($usedTags = array_reverse($usedTags)) ? '</' . implode('></', $usedTags) . '>' : '');
            $position = (int) end(
                                end(
                                    preg_split( '/<.*>| /',
                                                $html,
                                                -1,
                                                PREG_SPLIT_OFFSET_CAPTURE ) ) );
            $html .= $html2;
            $begin = substr( $html, 0, $position );
            $end = substr( $html, $position, ( strlen($html) - $position ) );
            preg_match_all('/<(.*?)>/s', $end, $usedTags);
            if ( strlen($text) > $length ) {
                $begin .= $endString;
            }
            $html = $begin . implode( $usedTags[0] );
            return $html;
        }


    public function getValueNameList( $infoPieces, $listAttributes = array(), $delimiter = ': ' ) {
        $infoItems = array();
        foreach( $infoPieces as $itemClass => $infoPiece ) {
            if ( $infoPiece['value'] == '' ) {
                continue;
            }



            $labelWrap = array( '<em>','</em>' );
            if ( isset($infoPiece['noWrapLabel']) && $infoPiece['noWrapLabel'] ) {
                $labelWrap = array( '', '');
            }
            $valueWrap = array( '<strong>','</strong>' );
            if ( isset($infoPiece['noWrapValue']) && $infoPiece['noWrapValue'] ) {
                $valueWrap = array( '', '');
            }

            $preTitle = $infoPiece['label'] != '' ? $labelWrap[0].$infoPiece['label'].$delimiter.$labelWrap[1] : '';

            $attributes = array();
            if ( isset($infoPiece['itemAttributes'])) {
                $attributes = $infoPiece['itemAttributes'];
            }

            $attributes = $this->view->formatUtil()->addItemToAttributes($attributes, 'class', $itemClass );

            $infoItems[] = array(
                'preTitleContent' => $preTitle,
                'title' => $valueWrap[0].$infoPiece['value'].$valueWrap[1],
                'itemAttributes' => $attributes,
            );

        }

        return $this->view->linkList($infoItems, $listAttributes );
    }



    public function getFormattedNumber($num, $precision = null ) {
        if ( !$num || !is_numeric( $num )  ) {
            return $num;
        }
        return number_format($num, $precision);

    }

    public function getTypeAheadAddressesScript($users = array(), $passedInUsers = array(), $includeLoginUser = false)
    {

        if( $passedInUsers ) {
            $users = array_merge( $passedInUsers, $users );
        }
        if ( $includeLoginUser && $this->view->loginUser) {
            $users[] = $this->view->loginUser;
        }
        $deDuped = array();
        $emails = array();
        if ( count($users) ) {
            foreach( $users as $thisUser ) {

                if ( !isset($deDuped[$thisUser->getId()])) {
                    $emails[] = array(
                        'id'    => $thisUser->getId(),
                        'last'  => $thisUser->getLastName($this->view->loginUser) ? $thisUser->getLastName($this->view->loginUser) : '',
                        'first' => $thisUser->getFirstName($this->view->loginUser) ? $thisUser->getFirstName($this->view->loginUser) : '',
                        'user'  => $thisUser->getDisplayName()
                    );
                    $deDuped[$thisUser->getId()] = true;
                }
            }
        }
        $json = Zend_Json::encode($emails);

        $xhtml = array();
        $xhtml[] = '<script type="text/javascript">';
        $xhtml[] = 'emails='.$json;
        $xhtml[] = '</script>';
        return join('', $xhtml);
    }


    public function getEmptyMessage( $text, $attributes = array() )
    {
        if ( !$text ) {
            return '';
        }
        if ( !is_array($text) ) {
            $text = array( $text );
        }

        $attributes = array_merge( array( 'class' => 'statusWrap' ), $attributes );

        $xhtml = array();
        $xhtml[] = '<div '.$this->view->htmlAttributes( $attributes ).'>';
        foreach( $text as $thisText ) {
            $xhtml[] = '<p>'.$thisText.'</p>';
        }
        $xhtml[] = '</div>';
        return join('',$xhtml);
    }


    public function getStatusMessage( $text, $type = 'info', $classes = array()  )
    {

        //types can be 'error', 'success', 'warning', 'info'

        if ( !$text ) {
            return '';
        }
        if ( !is_array($text) ) {
            $text = array( $text );
        }

        if ( !is_array($classes) ) {
            $classes = array( $classes );
        }


        $classes[] = 'statusMessage';
        $classes[] = 'statusMessage-'.$type;


        $xhtml = array();
        $xhtml[] = '<div class="'.join(' ', $classes).'">';
        foreach( $text as $thisText ) {
            $xhtml[] = '<p>'.$thisText.'</p>';
        }
        $xhtml[] = '</div>';
        return join('',$xhtml);
    }

    public function getHelpLink( $urlIndex, $text, $obj = null, $targetOpener = true )
    {

        if ( $this->view->network->getName() != 'kontend' ) {
            return '<strong>'.$text.'</strong>';
        }

        $linkParams = array();
        if ( !$obj ) {
            if  ( substr( $urlIndex, 0, 4) == 'user' || substr( $urlIndex, 0, 5) == 'group' ) {
                return '<strong>'.$text.'</strong>';
            }
        } else {
            if ( get_class( $obj ) == 'Sly_User' ) {
                $linkParams['userId'] = $obj->getId();
            } else if ( get_class( $obj ) == 'Sly_Group' ) {
                $linkParams['groupId'] = $obj->getId();
            }
        }

        $linkClass = '';
        if ( $targetOpener ) {
            $linkClass = ' class="popup target__opener"';

        }
        return '<a href="'.$this->view->url( $urlIndex, $linkParams ).'"'.$linkClass.'>'.$text.'</a>';
    }

    public function getPts( $pts, $wrap = true ) {
        if ( !$pts ) {
            $pts = 0;
        }

        $start = '';
        $end = '';
        if ( $wrap ) {
            if( $pts < 0){
                $start = '<span class="neg">';
                $end = '</span>';
            } else if( $pts > 0 ) {
                $start = '<span class="pos">+';
                $end = '</span>';
            }
        }
        return $start.$pts.$end;
    }

    public function getStatWinner( $val1, $val2, $reverse = false ) {

        if ( $reverse ) {
            $temp = $val2;
            $val2 = $val1;
            $val1 = $temp;
        }

        if ( $val1 > $val2 ) {
            return 1;
        } else if ( $val1 < $val2 ){
            return 2;
        } else {
            return 0;
        }
    }

    public function getRankSuffix( $val ) {

        $suffixNum = $val%10;
        if ( $suffixNum == 1 ) {
            $rankText = $val.'st';
        } else if ( $suffixNum == 2 ) {
            $rankText = $val.'nd';
        } else if ( $suffixNum == 3 ) {
            $rankText = $val.'rd';
        } else {
            $rankText = $val.'th';
        }
        return $rankText;
    }

    public function getTimezones()
    {
        return Sly_Date::getTimezones();
    }

    public function getStates()
    {

        $states = array(
            'AL' =>		'Alabama',
            'AK' =>		'Alaska',
            //'AS' =>		'American Samoa',
            'AZ' =>		'Arizona',
            'AR' =>		'Arkansas',
            'CA' =>		'California',
            'CO' =>		'Colorado',
            'CT' =>		'Connecticut',
            'DE' =>		'Delaware',
            'DC' =>		'District of Columbia',
            //'FM' =>		'Federated States of Micronesia',
            'FL' =>		'Florida',
            'GA' =>		'Georgia',
            //'GU' =>		'Guam',
            'HI' =>		'Hawaii',
            'ID' =>		'Idaho',
            'IL' =>		'Illinois',
            'IN' =>		'Indiana',
            'IA' =>		'Iowa',
            'KS' =>		'Kansas',
            'KY' =>		'Kentucky',
            'LA' =>		'Louisiana',
            'ME' =>		'Maine',
            //'MH' =>		'Marshall Islands',
            'MD' =>		'Maryland',
            'MA' =>		'Massachusetts',
            'MI' =>		'Michigan',
            'MN' =>		'Minnesota',
            'MS' =>		'Mississippi',
            'MO' =>		'Missouri',
            'MT' =>		'Montana',
            'NE' =>		'Nebraska',
            'NV' =>		'Nevada',
            'NH' =>		'New Hampshire',
            'NJ' =>		'New Jersey',
            'NM' =>		'New Mexico',
            'NY' =>		'New York',
            'NC' =>		'North Carolina',
            'ND' =>		'North Dakota',
            //'MP' =>		'Northern Mariana Islands',
            'OH' =>		'Ohio',
            'OK' =>		'Oklahoma',
            'OR' =>		'Oregon',
            //'PW' =>		'Palau',
            'PA' =>		'Pennsylvania',
            //'PR' =>		'Puerto Rico',
            'RI' =>		'Rhode Island',
            'SC' =>		'South Carolina',
            'SD' =>		'South Dakota',
            'TN' =>		'Tennessee',
            'TX' =>		'Texas',
            'UT' =>		'Utah',
            'VT' =>		'Vermont',
            //'VI' =>		'Virgin Islands',
            'VA' =>		'Virginia',
            'WA' =>		'Washington',
            'WV' =>		'West Virginia',
            'WI' =>		'Wisconsin',
            'WY' =>		'Wyoming',
        );

        return $states;
    }

    public function getCountries( )
    {
        $countries = array(
            'US' => array( 'text' => 'United States' ),
            'CA' => array( 'text' => 'Canada' ),
            'AF' => array( 'text' => 'Afghanistan' ),
            'AX' => array( 'text' => 'Aland Islands' ),
            'AL' => array( 'text' => 'Albania' ),
            'DZ' => array( 'text' => 'Algeria' ),
            'AS' => array( 'text' => 'American Samoa' ),
            'AD' => array( 'text' => 'Andorra' ),
            'AO' => array( 'text' => 'Angola' ),
            'AI' => array( 'text' => 'Anguilla' ),
            'AQ' => array( 'text' => 'Antarctica' ),
            'AG' => array( 'text' => 'Antigua and Barbuda' ),
            'AR' => array( 'text' => 'Argentina' ),
            'AM' => array( 'text' => 'Armenia' ),
            'AW' => array( 'text' => 'Aruba' ),
            'AU' => array( 'text' => 'Australia' ),
            'AT' => array( 'text' => 'Austria' ),
            'AZ' => array( 'text' => 'Azerbaijan' ),
            'BS' => array( 'text' => 'Bahamas' ),
            'BH' => array( 'text' => 'Bahrain' ),
            'BD' => array( 'text' => 'Bangladesh' ),
            'BB' => array( 'text' => 'Barbados' ),
            'BY' => array( 'text' => 'Belarus' ),
            'BE' => array( 'text' => 'Belgium' ),
            'BZ' => array( 'text' => 'Belize' ),
            'BJ' => array( 'text' => 'Benin' ),
            'BM' => array( 'text' => 'Bermuda' ),
            'BT' => array( 'text' => 'Bhutan' ),
            'BO' => array( 'text' => 'Bolivia' ),
            'BQ' => array( 'text' => 'Bonaire' ),
            'BA' => array( 'text' => 'Bosnia and Herzegovina' ),
            'BW' => array( 'text' => 'Botswana' ),
            'BV' => array( 'text' => 'Bouvet Island' ),
            'BR' => array( 'text' => 'Brazil' ),
            'IO' => array( 'text' => 'British Indian Ocean Territory' ),
            'BN' => array( 'text' => 'Brunei Darussalam' ),
            'BG' => array( 'text' => 'Bulgaria' ),
            'BF' => array( 'text' => 'Burkina Faso' ),
            'BI' => array( 'text' => 'Burundi' ),
            'KH' => array( 'text' => 'Cambodia' ),
            'CM' => array( 'text' => 'Cameroon' ),
            'CV' => array( 'text' => 'Cape Verde' ),
            'KY' => array( 'text' => 'Cayman Islands' ),
            'CF' => array( 'text' => 'Central African Republic' ),
            'TD' => array( 'text' => 'Chad' ),
            'CL' => array( 'text' => 'Chile' ),
            'CN' => array( 'text' => 'China' ),
            'CX' => array( 'text' => 'Christmas Island' ),
            'CC' => array( 'text' => 'Cocos (Keeling) Islands' ),
            'CO' => array( 'text' => 'Colombia' ),
            'KM' => array( 'text' => 'Comoros' ),
            'CG' => array( 'text' => 'Congo' ),
            'CD' => array( 'text' => 'Congo, Democratic Republic of the' ),
            'CK' => array( 'text' => 'Cook Islands' ),
            'CR' => array( 'text' => 'Costa Rica' ),
            'CI' => array( 'text' => "Cote D'Ivoire"),
            'HR' => array( 'text' => 'Croatia' ),
            'CU' => array( 'text' => 'Cuba' ),
            'CW' => array( 'text' => 'Curacao' ),
            'CY' => array( 'text' => 'Cyprus' ),
            'CZ' => array( 'text' => 'Czech Republic' ),
            'DK' => array( 'text' => 'Denmark' ),
            'DJ' => array( 'text' => 'Djibouti' ),
            'DM' => array( 'text' => 'Dominica' ),
            'DO' => array( 'text' => 'Dominican Republic' ),
            'EC' => array( 'text' => 'Ecuador' ),
            'EG' => array( 'text' => 'Egypt' ),
            'SV' => array( 'text' => 'El Salvador' ),
            'GQ' => array( 'text' => 'Equatorial Guinea' ),
            'ER' => array( 'text' => 'Eritrea' ),
            'EE' => array( 'text' => 'Estonia' ),
            'ET' => array( 'text' => 'Ethiopia' ),
            'FK' => array( 'text' => 'Falkland Islands' ),
            'FO' => array( 'text' => 'Faroe Islands' ),
            'FJ' => array( 'text' => 'Fiji' ),
            'FI' => array( 'text' => 'Finland' ),
            'FR' => array( 'text' => 'France' ),
            'GF' => array( 'text' => 'French Guiana' ),
            'PF' => array( 'text' => 'French Polynesia' ),
            'TF' => array( 'text' => 'French Southern Territories' ),
            'GA' => array( 'text' => 'Gabon' ),
            'GM' => array( 'text' => 'Gambia' ),
            'GE' => array( 'text' => 'Georgia' ),
            'DE' => array( 'text' => 'Germany' ),
            'GH' => array( 'text' => 'Ghana' ),
            'GI' => array( 'text' => 'Gibraltar' ),
            'GR' => array( 'text' => 'Greece' ),
            'GL' => array( 'text' => 'Greenland' ),
            'GD' => array( 'text' => 'Grenada' ),
            'GP' => array( 'text' => 'Guadeloupe' ),
            'GU' => array( 'text' => 'Guam' ),
            'GT' => array( 'text' => 'Guatemala' ),
            'GG' => array( 'text' => 'Guernsey' ),
            'GN' => array( 'text' => 'Guinea' ),
            'GW' => array( 'text' => 'Guinea-Bissau' ),
            'GY' => array( 'text' => 'Guyana' ),
            'HT' => array( 'text' => 'Haiti' ),
            'HM' => array( 'text' => 'Heard Island and McDonald Islands' ),
            'VA' => array( 'text' => 'Holy See (Vatican City State)' ),
            'HN' => array( 'text' => 'Honduras' ),
            'HK' => array( 'text' => 'Hong Kong' ),
            'HU' => array( 'text' => 'Hungary' ),
            'IS' => array( 'text' => 'Iceland' ),
            'IN' => array( 'text' => 'India' ),
            'ID' => array( 'text' => 'Indonesia' ),
            'IR' => array( 'text' => 'Iran, Islamic Republic of' ),
            'IQ' => array( 'text' => 'Iraq' ),
            'IE' => array( 'text' => 'Ireland' ),
            'IM' => array( 'text' => 'Isle of Man' ),
            'IL' => array( 'text' => 'Israel' ),
            'IT' => array( 'text' => 'Italy' ),
            'JM' => array( 'text' => 'Jamaica' ),
            'JP' => array( 'text' => 'Japan' ),
            'JE' => array( 'text' => 'Jersey' ),
            'JO' => array( 'text' => 'Jordan' ),
            'KZ' => array( 'text' => 'Kazakhstan' ),
            'KE' => array( 'text' => 'Kenya' ),
            'KI' => array( 'text' => 'Kiribati' ),
            'KP' => array( 'text' => "Korea, Democratic People's Republic of" ),
            'KR' => array( 'text' => 'Korea, Republic of' ),
            'KW' => array( 'text' => 'Kuwait' ),
            'KG' => array( 'text' => 'Kyrgyzstan' ),
            'LA' => array( 'text' => "Lao People's Democratic Republic"),
            'LV' => array( 'text' => 'Latvia' ),
            'LB' => array( 'text' => 'Lebanon' ),
            'LS' => array( 'text' => 'Lesotho' ),
            'LR' => array( 'text' => 'Liberia' ),
            'LY' => array( 'text' => 'Libyan Arab Jamahiriya' ),
            'LI' => array( 'text' => 'Liechtenstein' ),
            'LT' => array( 'text' => 'Lithuania' ),
            'LU' => array( 'text' => 'Luxembourg' ),
            'MO' => array( 'text' => 'Macao' ),
            'MK' => array( 'text' => 'Macedonia, The Former Yugoslav Republic of' ),
            'MG' => array( 'text' => 'Madagascar' ),
            'MW' => array( 'text' => 'Malawi' ),
            'MY' => array( 'text' => 'Malaysia' ),
            'MV' => array( 'text' => 'Maldives' ),
            'ML' => array( 'text' => 'Mali' ),
            'MT' => array( 'text' => 'Malta' ),
            'MH' => array( 'text' => 'Marshall Islands' ),
            'MQ' => array( 'text' => 'Martinique' ),
            'MR' => array( 'text' => 'Mauritania' ),
            'MU' => array( 'text' => 'Mauritius' ),
            'YT' => array( 'text' => 'Mayotte' ),
            'MX' => array( 'text' => 'Mexico' ),
            'FM' => array( 'text' => 'Micronesia, Federated States of' ),
            'MD' => array( 'text' => 'Moldova, Republic of' ),
            'MC' => array( 'text' => 'Monaco' ),
            'MN' => array( 'text' => 'Mongolia' ),
            'ME' => array( 'text' => 'Montenegro' ),
            'MS' => array( 'text' => 'Montserrat' ),
            'MA' => array( 'text' => 'Morocco' ),
            'MZ' => array( 'text' => 'Mozambique' ),
            'MM' => array( 'text' => 'Myanmar' ),
            'NA' => array( 'text' => 'Namibia' ),
            'NR' => array( 'text' => 'Nauru' ),
            'NP' => array( 'text' => 'Nepal' ),
            'NL' => array( 'text' => 'Netherlands' ),
            'NC' => array( 'text' => 'New Caledonia' ),
            'NZ' => array( 'text' => 'New Zealand' ),
            'NI' => array( 'text' => 'Nicaragua' ),
            'NE' => array( 'text' => 'Niger' ),
            'NG' => array( 'text' => 'Nigeria' ),
            'NU' => array( 'text' => 'Niue' ),
            'NF' => array( 'text' => 'Norfolk Island' ),
            'MP' => array( 'text' => 'Northern Mariana Islands' ),
            'NO' => array( 'text' => 'Norway' ),
            'OM' => array( 'text' => 'Oman' ),
            'PK' => array( 'text' => 'Pakistan' ),
            'PW' => array( 'text' => 'Palau' ),
            'PS' => array( 'text' => 'Palestinian Territory, Occupied' ),
            'PA' => array( 'text' => 'Panama' ),
            'PG' => array( 'text' => 'Papua New Guinea' ),
            'PY' => array( 'text' => 'Paraguay' ),
            'PE' => array( 'text' => 'Peru' ),
            'PH' => array( 'text' => 'Philippines' ),
            'PN' => array( 'text' => 'Pitcairn' ),
            'PL' => array( 'text' => 'Poland' ),
            'PT' => array( 'text' => 'Portugal' ),
            'PR' => array( 'text' => 'Puerto Rico' ),
            'QA' => array( 'text' => 'Qatar' ),
            'RE' => array( 'text' => 'Reunion' ),
            'RO' => array( 'text' => 'Romania' ),
            'RU' => array( 'text' => 'Russian Federation' ),
            'RW' => array( 'text' => 'Rwanda' ),
            'BL' => array( 'text' => 'Saint Barthelemy' ),
            'SH' => array( 'text' => 'Saint Helena' ),
            'KN' => array( 'text' => 'Saint Kitts and Nevis' ),
            'LC' => array( 'text' => 'Saint Lucia' ),
            'MF' => array( 'text' => 'Saint Martin' ),
            'PM' => array( 'text' => 'Saint Pierre And Miquelon' ),
            'VC' => array( 'text' => 'Saint Vincent and the Granadines' ),
            'WS' => array( 'text' => 'Samoa' ),
            'SM' => array( 'text' => 'San Marino' ),
            'ST' => array( 'text' => 'Sao Tome and Principe' ),
            'SA' => array( 'text' => 'Saudi Arabia' ),
            'SN' => array( 'text' => 'Senegal' ),
            'RS' => array( 'text' => 'Serbia' ),
            'SC' => array( 'text' => 'Seychelles' ),
            'SL' => array( 'text' => 'Sierra Leone' ),
            'SG' => array( 'text' => 'Singapore' ),
            'SX' => array( 'text' => 'Sint Maarten' ),
            'SK' => array( 'text' => 'Slovakia' ),
            'SI' => array( 'text' => 'Slovenia' ),
            'SB' => array( 'text' => 'Solomon Islands' ),
            'SO' => array( 'text' => 'Somalia' ),
            'ZA' => array( 'text' => 'South Africa' ),
            'GS' => array( 'text' => 'South Georgia and the South Sandwich Islands' ),
            'ES' => array( 'text' => 'Spain' ),
            'LK' => array( 'text' => 'Sri Lanka' ),
            'SD' => array( 'text' => 'Sudan' ),
            'SR' => array( 'text' => 'Suriname' ),
            'SJ' => array( 'text' => 'Svalbard and Jan Mayen' ),
            'SZ' => array( 'text' => 'Swaziland' ),
            'SE' => array( 'text' => 'Sweden' ),
            'CH' => array( 'text' => 'Switzerland' ),
            'SY' => array( 'text' => 'Syrian Arab Republic' ),
            'TW' => array( 'text' => 'Taiwan, Province of China' ),
            'TJ' => array( 'text' => 'Tajikistan' ),
            'TZ' => array( 'text' => 'Tanzania, United Republic of' ),
            'TH' => array( 'text' => 'Thailand' ),
            'TL' => array( 'text' => 'Timor-Leste' ),
            'TG' => array( 'text' => 'Togo' ),
            'TK' => array( 'text' => 'Tokelau' ),
            'TO' => array( 'text' => 'Tonga' ),
            'TT' => array( 'text' => 'Trinidad and Tobago' ),
            'TN' => array( 'text' => 'Tunisia' ),
            'TR' => array( 'text' => 'Turkey' ),
            'TM' => array( 'text' => 'Turkmenistan' ),
            'TC' => array( 'text' => 'Turks and Caicos Islands' ),
            'TV' => array( 'text' => 'Tuvalu' ),
            'UG' => array( 'text' => 'Uganda' ),
            'UA' => array( 'text' => 'Ukraine' ),
            'AE' => array( 'text' => 'United Arab Emirates' ),
            'GB' => array( 'text' => 'United Kingdom' ),
            'UM' => array( 'text' => 'United States Minor Outlying Islands' ),
            'UY' => array( 'text' => 'Uruguay' ),
            'UZ' => array( 'text' => 'Uzbekistan' ),
            'VU' => array( 'text' => 'Vanuatu' ),
            'VE' => array( 'text' => 'Venezuela' ),
            'VN' => array( 'text' => 'Viet Nam' ),
            'VG' => array( 'text' => 'Virgin Islands, British' ),
            'VI' => array( 'text' => 'Virgin Islands, U.S.' ),
            'WF' => array( 'text' => 'Wallis and Futuna' ),
            'EH' => array( 'text' => 'Western Sahara' ),
            'YE' => array( 'text' => 'Yemen' ),
            'ZM' => array( 'text' => 'Zambia' ),
            'ZW' => array( 'text' => 'Zimbabwe')
        );

        return $countries;
    }

    public function getStateNameByAbbr( $stateAbbr )
    {

        if ( ! $stateAbbr ) {
            return '';
        }

        $states = $this->getStates();
        $stateAbbr = strtoupper($stateAbbr);

        if ( isset( $states[$stateAbbr] ) ) {
            return $states[$stateAbbr];
        } else {
            return '';
        }

    }

    public function encodeForAlert( $message ) {
        return preg_replace("/\r?\n/", "\\n", addslashes($message));
    }

    public function dumpArray( $var ) {
        return '<pre>'.print_r($var, true).'</pre>';
    }

    public function replaceTextWithLinks($tokens = array(), $text, $limit = -1, $caseSensitive = true )
    {
        // $tokens is an associative array with two elements 'find' and 'replace'
        foreach( $tokens as $token ) {
            $find = $token['find'];
            $replace = $token['replace'];

            // first replace all references to internal code
            if ( $caseSensitive ) {
                $text = str_replace( $find, '__SLY_TEXT_REPLACE__', $text );
            }
            else {
                $text = str_ireplace( $find, '__SLY_TEXT_REPLACE__', $text );
            }

            // put back those that are in <a href=""></a>
            // changed to use non-greedy on the </a> then chnage back
            $text = preg_replace( "/(<a[^>]*>.*?)(__SLY_TEXT_REPLACE__)([^(<\/a>)]*?<\/a>)/i", "$1$find$3", $text );
            //$text = preg_replace( "/(<a[^>]*>.*?)(__SLY_TEXT_REPLACE__)(.*?<\/a>)/i", "$1$find$3", $text );

            // put back those that are part of the link href=""
            $text = preg_replace( "/(href=\"[^\"]*)(__SLY_TEXT_REPLACE__)([^\"]*\")/i", "$1$find$3", $text );

            // put back those that are part of the link alt=""
            $text = preg_replace( "/(alt=\"[^\"]*)(__SLY_TEXT_REPLACE__)([^\"]*\")/i", "$1$find$3", $text );


            // replace the other ones up to limit
            $text = preg_replace( '/__SLY_TEXT_REPLACE__/', $replace, $text, $limit );

            // replace anything left over
            $text = str_replace( '__SLY_TEXT_REPLACE__', $find, $text );
        }

        return $text;
    }

    public function linkTwitterNames( $text )
    {

        if ( preg_match_all( '/\@[a-zA-Z0-9_]+/', $text, $matches ) ) {
            foreach( $matches[0] as $match ) {
                $name = str_replace( '@', '', $match );

                $text = str_replace( $match, "<a href=\"http://twitter.com/$name\">$match</a>", $text );
            }
        }

        return $text;
    }

    /*
     * Copied from http://www.snipe.net/2009/09/php-twitter-clickable-links/
     */
    public function activateLinks($text, $target = "_blank")
    {
        $text = preg_replace("#(^|[\n ])([\w]+?://[\w]+[^ \"\n\r\t< ]*)#", "\\1<a href=\"\\2\" target=\"" . $target . "\">\\2</a>", $text);
        $text = preg_replace("#(^|[\n ])((www|ftp)\.[^ \"\t\n\r< ]*)#", "\\1<a href=\"http://\\2\" target=\"" . $target . "\">\\2</a>", $text);
        // @user
        //$text = preg_replace("/@(\w+)/", "<a href=\"http://www.twitter.com/\\1\" target=\"_blank\">@\\1</a>", $text);
        // Hash tags #
        //$text = preg_replace("/#(\w+)/", "<a href=\"http://search.twitter.com/search?q=\\1\" target=\"_blank\">#\\1</a>", $text);
        return $text;
    }

    public function filterProfanity( $text )
    {
        $words = array( 'fuck', 'shit', 'dick', 'cock', 'pussy', 'cunt', 'bitch', 'tits', 'nigger', 'nigga', 'whore', 'slut', 'blowjob', 'clit', 'faggot', );

        foreach( $words as $word ) {
            if ( preg_match_all( '/\b'.$word.'[^\s]*/i', $text, $matches ) ) {
                foreach( $matches[0] as $match ) {
                    $replacement = $match[0] . str_repeat( '*', strlen( $match ) - 1 );

                    $text = str_replace( $match, $replacement, $text );
                }
            }
        }

        return $text;
    }


    public function getOrdinal($num, $justOrdinal = false ) {
        if( $justOrdinal ) {
            return $this->getJustOrdinal( $num );
        } else {
            return $num.$this->getJustOrdinal( $num );
        }
    }


    public function getJustOrdinal($num ) {
        $numLast = $num % 100;
        if (($numLast > 10 && $numLast < 14) || $num == 0){
            return "th";
        }
        switch(substr($num, -1)) {
            case '1':    return "st";
            case '2':    return "nd";
            case '3':    return "rd";
            default:     return "th";
        }
    }

    public function toSentence($array)
    {
        $count = count($array);
        switch ($count)
        {
            case 0:
                $str = '';
                break;
            case 1:
                $str = $array[0];
                break;
            case 2:
                $str = $array[0].' and '.$array[1];
                break;
            default:
                $str = implode(', ', array_slice($array, 0, -1)).' and '.$array[($count - 1)];
                break;
        }

        return $str;
    }

    public function httpBuildQuery3986( array $params, $sep = '&' )
    {
        $parts = array();
        foreach ( $params as $key => $value ) {
            $parts[] = sprintf( '%s=%s', $key, rawurlencode($value) );
        }
        return implode($sep, $parts);
    }


    public function setView( Zend_View_Interface $view )
    {
        $this->view = $view;
    }

}
