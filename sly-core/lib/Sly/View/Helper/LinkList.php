<?php

/**
 * Zend_View_Helper_FormELement
 */
require_once 'Zend/View/Helper/FormElement.php';


class Sly_View_Helper_LinkList extends Zend_View_Helper_FormElement
{

    /**
     * Generates a 'List' element.
     *
     * @param array   $items   Array with the elements of the list
     * @param array   $initVars Array with list settings
     *                    'selected' = selected item to highlight
     *                    'attributes' = UL/OL attributes
     *                    'ordered' = UL or OL
     *                    'oddAndEven' = write out odd and even classes for items
     *                    'noLinkWrap' = tag to wrap around title if no link specified.
     * @return string The list XHTML.
     */
    public function linkList(array $items, array $initVars = null)
    {

        $selected = isset($initVars['selected']) ? $initVars['selected'] : null;
        $selectedClass = isset($initVars['selectedClass']) ? $initVars['selectedClass'] : 'selected';
        $listAttributes = isset($initVars['attributes']) ? $initVars['attributes'] : null;
        $ordered = isset($initVars['ordered']) ? $initVars['ordered'] : false;
        $oddAndEven  = isset($initVars['oddAndEven']) ? $initVars['oddAndEven'] : false;
        $noLinkWrapTag = isset($initVars['noLinkWrap']) ? $initVars['noLinkWrap'] : false;
        $extraTitleWrapTag = isset($initVars['extraTitleWrapTag']) ? $initVars['extraTitleWrapTag'] : false;
        $justItems = isset($initVars['justItems']) ? $initVars['justItems'] : false;
        $justContent = isset($initVars['justContent']) ? $initVars['justContent'] : false;
        $wrapContent = isset($initVars['wrapContent']) ? $initVars['wrapContent'] : true;

        if (!is_array($items)) {
            require_once 'Zend/View/Exception.php';
            throw new Zend_View_Exception('First param must be an array', $this);
        }

        $list = '';
        $totalItems = count($items);
        $curCount = 0;

        foreach ($items as $key=>$item) {

			if ( isset($item['title']) && $item['title'] == '' ) {
                $totalItems--;
            }
        }

        foreach ($items as $key=>$item) {

            if ( isset($item['title']) && $item['title'] == '' ) {
                continue;
            }

            if ( $extraTitleWrapTag ) {
                $title = '<'.$extraTitleWrapTag.'>'.$item['title'].'</'.$extraTitleWrapTag.'>';
            } else {
                $title = $item['title'];
			}

            if (isset($item['link']) && $title ) {
                $linkAttributes = isset($item['linkAttributes']) ? $this->_htmlAttribs($item['linkAttributes']) : '';
                $middle = '<a href="' . $item['link'] . '" ' .$linkAttributes. '>' . $title . '</a>';
            } else if ($noLinkWrapTag && $title ) {
                $linkAttributes = isset($item['linkAttributes']) ? $this->_htmlAttribs($item['linkAttributes']) : '';
                $middle = '<'.$noLinkWrapTag.$linkAttributes.'>'.$title.'</'.$noLinkWrapTag.'>';
            } else {
                $middle = $title != '' ? $title : '';
            }

            $semanticClass =  $this->view->getSemanticClass( $curCount, $totalItems, (string) $key, (string) $selected, $oddAndEven, $selectedClass);

            //addin semantic class to class item in itemAttributes
            if ( $semanticClass ) {
				if (isset($item['itemAttributes'])) {
					if (isset($item['itemAttributes']['class'])) {
						$item['itemAttributes']['class'] .= " $semanticClass";
                    } else {
						$item['itemAttributes']['class'] = $semanticClass;
                    }
                } else {
                    $item['itemAttributes'] = array( 'class'=>  $semanticClass );
                }
            }

            $beginning = isset($item['preTitleContent']) ? $item['preTitleContent'] : '';
            $end = isset($item['postTitleContent']) ? $item['postTitleContent'] : '';

            $itemAttributes = isset($item['itemAttributes']) ? $this->_htmlAttribs($item['itemAttributes']) : '';

			if ( !$justContent ) {
				$list .= '<li' . $itemAttributes . '>' . $beginning . $middle . $end . '</li>';
			} else if ( !$wrapContent ) {
				$list .= $beginning . $middle . $end ;
			} else {
				$list .= '<div' . $itemAttributes . '>' . $beginning . $middle . $end . '</div>';
			}

            $curCount++;
        }

        if ($listAttributes) {
            $listAttributes = $this->_htmlAttribs($listAttributes);
        } else {
            $listAttributes = '';
        }

        if ( $curCount ) {

            if( $justItems || $justContent ){
                return $list;
            } else {

                $tag = 'ul';
                if ($ordered) {
                    $tag = 'ol';
                }

                return '<' . $tag . $listAttributes . '>' . $list . '</' . $tag . '>';
            }
        } else {
            return '';
        }
    }

}
