<?php

/**
 * Helper for creating item pagination, as described by pattern
 * http://developer.yahoo.com/ypatterns/pattern.php?pattern=itempagination
 */
class Sly_View_Helper_ItemPagination
{
    /**
     * The view object that created this helper object.
     * @var Zend_View
     */
    public $view;


     /**
     * Generates a 'List' element.
     *
     * @param array   $initVars Array with list settings
     *                    'paginationParams' = params to pass in
     *                    'paramToReplace' = index to put into url defaults to 'offset'
     *                    'urlIndex' = sly_url index
     *                    'unsetIfDefault' = no show paramToReplace if default
     *                    'defaultValue' = 1
     *                    'offset' = current item
     *                    'totalItems' = total number of items - can be a string like 'a whole bunch'
     *                    'perPage' = number of items per page
     *                    'itemType' = title for type of items
     *                    'labels' = strings for array(first,prev,next,last)
     *                    'containerAttributes' = attributes for div wrapping everthing.
     *                    'dynamicLinks' = add dynamic class to links?
     *                    'hideFirstLast' = hide first and last links?
     * @return string The list XHTML.
     */
    public function itemPagination(array $initVars )
    {

        //items will be numbered starting with1.
        $perPage = (isset($initVars['perPage']) && $initVars['perPage'] > 0) ? $initVars['perPage'] : 5;

        $paramToReplace = (isset($initVars['paramToReplace'])) ? $initVars['paramToReplace'] : 'offset';

        $urlIndex = (isset($initVars['urlIndex'])) ? $initVars['urlIndex'] : null;
        $paginationParams = (isset($initVars['paginationParams'])) ? $initVars['paginationParams'] : array();

        $defaultValue = isset($initVars['defaultValue']) ? $initVars['defaultValue'] : 1;
        $offset = isset($initVars['offset']) ? $initVars['offset'] : $defaultValue;
        $objects = isset($initVars['itemType']) ? $initVars['itemType']: '';
        $unsetIfDefault = isset($initVars['unsetIfDefault']) ? $initVars['unsetIfDefault']: false;
        $containerAttributes = isset($initVars['containerAttributes']) ? $initVars['containerAttributes'] : array( 'class' => 'pagination item');
        $total = isset($initVars['totalItems']) ? $initVars['totalItems'] : 'Lots and Lots';
        $usePages = isset($initVars['usePages']) ? $initVars['usePages'] : false;
        $dynamicLinks = isset($initVars['dynamicLinks']) ? $initVars['dynamicLinks'] : false;
        $hideFirstLast = isset($initVars['hideFirstLast']) ? $initVars['hideFirstLast'] : false;
        $hideIfEmpty = isset($initVars['hideIfEmpty']) ? $initVars['hideIfEmpty'] : false;
        $showPaginationIfOnePage = isset($initVars['showPaginationIfOnePage']) ? $initVars['showPaginationIfOnePage'] : false;
        $displayPrefix = isset($initVars['displayPrefix']) ? $initVars['displayPrefix'] : '';
        $wrapLabelNumbers = isset($initVars['wrapLabelNumbers']) ? $initVars['wrapLabelNumbers'] : false;
        $linkAttributes = isset($initVars['linkAttributes']) ? $initVars['linkAttributes'] : false;

        $curPage = ($offset%$perPage) ? ceil($offset/$perPage)  : $offset/$perPage;
        $lastPage = is_numeric($total) ? ceil($total/$perPage) : 100000;

        if ( $total == 0 && $hideIfEmpty) {
            return '';
        }

        if ( $lastPage == 1 && !$showPaginationIfOnePage ) {
            return '';
        }

        if(  $curPage > $lastPage || $curPage < 1 ) {
           $curPage = 1;
        }

        $labels = isset($initVars['labels']) ? $initVars['labels'] : array( 'First','Prev','Next','Last');

        $listItems = array();


        $newPaginationParams = array_merge( $paginationParams, array( $paramToReplace => 1 ) );
        if ( $unsetIfDefault && $newPaginationParams[$paramToReplace] == $defaultValue ) {
            unset( $newPaginationParams[$paramToReplace] );
        }
        $listItems['first'] = array(
            'title' => $labels[0],
            'link' => $this->view->url($urlIndex, $newPaginationParams ),
        );

        $newPaginationParams = array_merge( $paginationParams, array( $paramToReplace => ($curPage-2)*$perPage+1 ) );
        if ( $unsetIfDefault && $newPaginationParams[$paramToReplace] == $defaultValue ) {
            unset( $newPaginationParams[$paramToReplace] );
        }

        $listItems['prev'] = array(
                'title' => $labels[1],
                'link' => $this->view->url($urlIndex, $newPaginationParams ),
                'itemAttributes' => array( 'class' => 'prev previous'),
        );

        $newPaginationParams = array_merge( $paginationParams, array( $paramToReplace => ($curPage)*$perPage+1 ) );
        if ( $unsetIfDefault && $newPaginationParams[$paramToReplace] == $defaultValue ) {
            unset( $newPaginationParams[$paramToReplace] );
        }
        $listItems['next'] = array(
            'title' => $labels[2],
            'link' => $this->view->url($urlIndex, $newPaginationParams ),
            'itemAttributes' => array( 'class' => 'next'),
        );

        $newPaginationParams = array_merge( $paginationParams, array( $paramToReplace => ($lastPage-1)*$perPage+1) );
        if ( $unsetIfDefault && $newPaginationParams[$paramToReplace] == $defaultValue ) {
            unset( $newPaginationParams[$paramToReplace] );
        }

        $listItems['last'] = array(
            'title' => $labels[3],
            'link' => $this->view->url($urlIndex, $newPaginationParams ),
        );

        if ($total == 0) {
            unset($listItems['first']['link']);
            unset($listItems['prev']['link']);
            unset($listItems['next']['link']);
            unset($listItems['last']['link']);
            $title = 'There are no items to display';
        } else {
            if ($curPage == 1) {
                unset($listItems['first']['link']);
                unset($listItems['prev']['link']);
            }
            if ($curPage == $lastPage){
                unset($listItems['next']['link']);
                unset($listItems['last']['link']);
            }
            if (!is_numeric($total)) {
                unset($listItems['last']['link']);
            }
            $finalItem = $perPage*$curPage;
            if (is_numeric($total) && $finalItem > $total) {
                $finalItem = $total;
            }
            $wrapLableNumberTags = array( '', '' );
            if ( $wrapLabelNumbers ) {
                $wrapLableNumberTags = array( '<em>', '</em>' );
            }


            if ( !$usePages ) {
                $title = $displayPrefix.' ';
                $title .= $wrapLableNumberTags[0].(($perPage*($curPage-1))+1 ) .' - '. $finalItem.$wrapLableNumberTags[1].' of '.$wrapLableNumberTags[0].$total.$wrapLableNumberTags[1].' '.$objects;
            } else {
                $title = $displayPrefix.' ';
                $title .= $wrapLableNumberTags[0].ceil((($perPage*($curPage-1))+1)/$perPage) .$wrapLableNumberTags[1].' of '.$wrapLableNumberTags[0].ceil($total/$perPage).$wrapLableNumberTags[1]. ' '.$objects;
            }
            if ($dynamicLinks) {
                foreach($listItems as $key=>$listItem){
                    $listItems[$key]['linkAttributes'] = array('class' => 'dynamic');
                }
            } else if ( $linkAttributes ) {
                foreach($listItems as $key=>$listItem){
                    $listItems[$key]['linkAttributes'] = $linkAttributes;
                }
            }


        }

        if ($hideFirstLast) {
            unset($listItems['first']);
            unset($listItems['last']);
        }

        $xhtml = '<div'.$this->view->htmlAttributes($containerAttributes).'>';
        $xhtml .= '<span class="paginationLabel">'.$title.'</span>';
        $xhtml .= $this->view->linkList($listItems, array( 'noLinkWrap' => 'span',
                                                           'attributes' => array('class' => 'unstyled pager')));
        $xhtml .= '</div>';

        return $xhtml;

    }

    public function setView(Zend_View_Interface $view)
    {
        $this->view = $view;
    }
}
