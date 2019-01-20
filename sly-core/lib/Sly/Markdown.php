<?php

// site using this class, must already include the markdown files listed here
//require_once( SLY_ROOT_DIR . '/vendors/markdown/Markdown.php' );
//require_once( SLY_ROOT_DIR . '/vendors/markdown/MarkdownExtra.php' );

class Sly_Markdown
{
    const TAG = '(?P<tag>[a-z][^\s\/>]*)';
    const ATTRIBUTE = '(?P<name>[^\s\/=]+)(?:\s*=\s*(?P<value>"[^"]*"|\'[^\']*\'))?';
    private static $SELF_CLOSING_TAGS = array(
        'area' => 1,
        'base' => 1,
        'br' => 1,
        'col' => 1,
        'command' => 1,
        'embed' => 1,
        'hr' => 1,
        'img' => 1,
        'input' => 1,
        'keygen' => 1,
        'link' => 1,
        'meta' => 1,
        'param' => 1,
        'source' => 1,
        'track' => 1,
        'wbr' => 1
    );
    private static $SKIP_TAGS = array(
        'script' => 1,
        'style' => 1
    );
    
    public static function getStructured($markup, $site, $responseData, $gallery = null)
    {
        $markup = MarkdownExtra::defaultTransform(trim($markup));
        if (isset($_GET['html'])) {
            return $markup;
        }
        
        $tokens = array(
            'openTag' => '/<'.self::TAG.'(?P<attributes>(?:\s+'.self::ATTRIBUTE.')*)\s*\/?>/is',
            'comment' => '/<!--(?P<content>.*?)-->/s',
            'closeTag' => '/<\/'.self::TAG.'>/is',
        );
        
        $stack = array();
        $node = array();
        $i = 0;
        $skip = 0;
        $length = strlen($markup);
        
        if ($gallery) {
            $responseData->addContentDetails($gallery);
        }

        while ($i < $length) {
            $token = null;
            $match = null;
            $start = $length;
            foreach ($tokens as $type => $regex) {
                if (preg_match($regex, $markup, $m, PREG_OFFSET_CAPTURE, $i) && $m[0][1] < $start) {
                    $token = $type;
                    $match = $m;
                    $start = $m[0][1];
                }
            }
            if ($start > $i) {
                $text = substr($markup, $i, $start-$i);
                if (!$skip && preg_match('/\S+/', $text)) { // skip whitespace-only nodes
                    $node[] = array('text' => html_entity_decode(self::processEntities($text, $site, $responseData)));
                }
                $i = $start;
            }
            if ($match) {
                $text = $match[0][0];
                if ($token == 'comment') {
                    if (!$skip) {
                        $element = array('tag' => 'content');
                        preg_match_all('/'.self::ATTRIBUTE.'/s', $match['content'][0], $matches, PREG_SET_ORDER);
                        foreach ($matches as $m) {
                            if (isset($m['value'])) {
                                $element[$m['name']] = substr($m['value'], 1, -1);
                            } else {
                                $element['contentType'] = $m['name'];
                            }
                        }
                        if (isset($element['contentType'])) {
                            if ($element['contentType'] == 'gallery' && $gallery) {
                                $element['contentType'] = 'collection';
                                $element['id'] = $gallery->getId();
                                $gallery = null;
                            } else if ($element['contentType'] == 'brackify') {
                                // noop (see #24232)
                            } else if ($content = $site->getContent(@$element['id'])) {
                                $responseData->addContentDetails($content);
                            }
                            $node[] = $element;
                        }
                    }
                } else if ($token == 'openTag') {
                    $tag = strtolower($match['tag'][0]);
                    $selfClosing = substr($text, -2, 1) == '/' || isset(self::$SELF_CLOSING_TAGS[$tag]);
                    if (isset(self::$SKIP_TAGS[$tag])) {
                        if (!$selfClosing) $skip++;
                    } else if (!$skip) {
                        $element = array('tag' => $tag);
                        if (isset($match['attributes']) && preg_match_all('/'.self::ATTRIBUTE.'/s', $match['attributes'][0], $matches, PREG_SET_ORDER)) {
                            foreach ($matches as $m) {
                                $element[$m['name']] = isset($m['value']) ? substr(self::processEntities($m['value'], $site, $responseData), 1, -1) : true;
                            }
                        }
                        $url = false;
                        if ($tag == 'a' && isset($element['href'])) $url = 'href';
                        if ($tag == 'img' && isset($element['src'])) $url = 'src';
                        if ($url) {
                            $element[$url] = trim($element[$url]);
                            if (!preg_match('/^(?:@@|https?:\/\/)/', $element[$url])) {
                                $element[$url] = 'http://'.$element[$url];
                            }
                        }
                        $node[] = $element;
                        if (!$selfClosing) {
                            $element['children'] = array();
                            $tmp = &$node[count($node)-1]['children'];
                            $stack[count($stack)] = &$node;
                            unset($node);
                            $node = &$tmp;
                            unset($tmp);
                        }
                    }
                } else if ($skip && isset(self::$SKIP_TAGS[strtolower($match['tag'][0])])) {
                    $skip--;
                } else {
                    unset($node);
                    $node = &$stack[count($stack)-1]; // array_pop does not return a reference, so assign here
                    $children = $node[count($node)-1]['children'];
                    $childCount = count($children);
                    if (!$childCount || $childCount == 1 && !isset($children[0]['tag'])) {
                        if ($childCount) {
                            $node[count($node)-1]['text'] = $children[0]['text'];
                        }
                        unset($node[count($node)-1]['children']);
                    }
                    array_pop($stack);
                }
                $i += strlen($text);
            }
        }
        if ($gallery) {
            $node[] = array('tag' => 'content', 'contentType' => 'collection', 'id' => $gallery->getId());
        }
        // for now dave wants the body to be a string
        return json_encode($node);
    }
    
    /* Calls $responseData->addAthleteBasic or $responseData->addContentDetails
       for @@ style references in text */
    public static function processEntities($text, $site, $responseData)
    {
        preg_match_all('/@@(?P<type>[^:@]+):(?P<url>[^@]+)@@/', $text, $matches, PREG_SET_ORDER);
        foreach ($matches as $match) {
            $url = parse_url($match['url']);
            $id = isset($url['path']) ? $url['path'] : '';
            switch ($match['type']) {
                case 'post':
                    // for now, we aren't going to process the post page at all
                    break;
                default:
                    if ($content = $site->getContent($id)) {
                        $responseData->addContentDetails($content);
                    }
                    break;
            }
        }
        return $text;
    }
}
