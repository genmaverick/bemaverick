<?php

/**
 * Helper for creating item pagination, as described by pattern
 * http://developer.yahoo.com/ypatterns/pattern.php?pattern=itempagination
 */
class Sly_View_Helper_SearchPagination
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
     *                    'paginationParams' = url to use with '%offset%' as place holder for input*
     *                    'offset' = current item
     *                    'totalItems' = total number of items - can be a string like 'a whole bunch'
     *                    'perPage' = number of items per page
     *                    'itemType' = title for type of items
     *                    'labels' = strings for array(first,prev,next,last)
     *                    'containerAttributes' = attributes for div wrapping everthing.
     *                    'pages' = max number of pages to show defaults to 11
     *                    'emptyMessage' = what to print out when nothing is found
     *                    'hideIfEmpty = true
     *                    'showPaginationIfOnePage' = false
     *                    'ellipsisize' = false
     * @return string The list XHTML.
     */
    public function searchPagination(array $initVars )
    {

        //pages will be numbered starting with 1.
        $perPage = (isset($initVars['perPage']) && $initVars['perPage'] > 0) ? $initVars['perPage'] : 5;

        $paramToReplace = (isset($initVars['paramToReplace'])) ? $initVars['paramToReplace'] : 'offset';
        $urlIndex = (isset($initVars['urlIndex'])) ? $initVars['urlIndex'] : null;
        $showItemTitles = (isset($initVars['showItemTitles'])) ? $initVars['showItemTitles'] : false;
        $showItemCounts = (isset($initVars['showItemCounts'])) ? $initVars['showItemCounts'] : true;
        $paginationParams = (isset($initVars['paginationParams'])) ? $initVars['paginationParams'] : array();
        $title = '';
        $offset = isset($initVars['offset']) ? $initVars['offset'] : 1;
        $of = isset($initVars['of']) ? $initVars['of'] : 'of';
        $objects = isset($initVars['itemType']) ? $initVars['itemType']: '';
        $containerAttributes = isset($initVars['containerAttributes']) ? $initVars['containerAttributes'] : array( 'class' => 'pagination search');
        $total = isset($initVars['totalItems']) ? $initVars['totalItems'] : 'Lots and Lots';
        $displayPrefix = isset($initVars['displayPrefix']) ? $initVars['displayPrefix'] : '';
        $hideIfEmpty = isset($initVars['hideIfEmpty']) ? $initVars['hideIfEmpty'] : false;
        $showPaginationIfOnePage = isset($initVars['showPaginationIfOnePage']) ? $initVars['showPaginationIfOnePage'] : false;
        $linkAttributes = isset($initVars['linkAttributes']) ? $initVars['linkAttributes'] : false;
        $linkCurrent = isset($initVars['linkCurrent']) ? $initVars['linkCurrent'] : false;
        $alwaysShowPrevNext = isset($initVars['alwaysShowPrevNext']) ? $initVars['alwaysShowPrevNext'] : false;

        $showFirstLast = isset( $initVars['hideFirstLast'] ) ? !$initVars['hideFirstLast'] : false;
        $alwaysShowFirstLast = isset($initVars['alwaysShowFirstLast']) ? $initVars['alwaysShowFirstLast'] : false;
        $ellipsisize = isset($initVars['ellipsisize']) ? $initVars['ellipsisize'] : false;

        $listAttributes = isset($initVars['listAttributes']) ? $initVars['listAttributes'] : array();

        if ( $total == 0 && $hideIfEmpty) {
            return '';
        }

        $pages = isset($initVars['pages']) ? $initVars['pages'] : 9;
        $labels = isset($initVars['labels']) ? $initVars['labels'] : ( $showFirstLast ? array( '< First', '< Prev','Next >', 'Last >') : array('< Prev','Next >') );

        if ( $showFirstLast && count( $labels ) < 4 ) {
            $labels = array( '< First', '< Prev','Next >', 'Last >');
        }

        $curPage = ($offset%$perPage) ? ceil($offset/$perPage)  : $offset/$perPage;
        $lastPage = is_numeric($total) ? ceil($total/$perPage) +1 : 100000;

        if(  $curPage > $lastPage || $curPage < 1 ) {
           $curPage = 1;
        }
        $half = ceil($pages/2);

		$curPageIndex = (int) $curPage - 1;

        $listItems = array();
        if( $lastPage > $pages && $curPage > $half ) {
            if( $curPage+1 + $half > $lastPage ) {
                $rangeEnd = $lastPage;
                $rangeStart = $lastPage - $pages;
            } else {
                $rangeStart = $curPage+1 - $half;
                $rangeEnd = $rangeStart + $pages;
            }
        } else {
            $rangeStart = 1;
            $rangeEnd = $lastPage > $pages ? $rangeStart+$pages : $lastPage;
        }





        if($total===0) {
            $title = isset($initVars['emptyMessage']) ? $initVars['emptyMessage'] : 'There are no items to Display';
        } else {

            if ( $alwaysShowFirstLast || ( $curPage != 1 && $showFirstLast && $lastPage > 1 ) ) {
                
                $paginationParams[$paramToReplace] = 1;
                $listItems['first'] = array(
                    'title' => $labels[0],
                    'link' => $this->view->url($urlIndex, $paginationParams ),
                    'itemAttributes' => array(
                        'class' => 'firstitem',
                     ),                    
                );
                if ( $linkAttributes ) {
                     $listItems['first']['linkAttributes'] = $linkAttributes;
                }

                if ( $curPage == 1 && $alwaysShowFirstLast ) {
                    unset($listItems['first']['link']);
                }
            }



            if( $curPage != 1 || $alwaysShowPrevNext ) {
                $paginationParams[$paramToReplace] = ($curPage-2)*$perPage+1;
                $listItems['prev'] = array(
                    'title' => ( $showFirstLast ? $labels[1] : $labels[0] ),
                    'link' => $this->view->url($urlIndex, $paginationParams),
                    'itemAttributes' => array(
                        'class' => 'prev',
                     ),
                );
                if ( $showItemTitles ) {
                    $listItems['prev']['itemAttributes']['title'] = 'Results '.(($curPage-2)*$perPage+1).'-'.(($curPage-1)*$perPage);
                }

                if ( $linkAttributes ) {
                     $listItems['prev']['linkAttributes'] = $linkAttributes;
                }
                if ( $curPage == 1 && $alwaysShowPrevNext ) {
                    unset($listItems['prev']['link']);
                }
            }

			$beginIndex = $rangeStart;
			$endIndex = $rangeEnd;
			if ($ellipsisize) {
                // Want to consider ALL nav entries
				$beginIndex = 1;
				$endIndex = $lastPage;
			}

            for($i = $beginIndex; $i< $endIndex; $i++) {
                if ($i == $lastPage-1) {
                    $titleEnd = $total;
                } else {
                    $titleEnd = $i*$perPage;
                }

				$itemIndex = "pageNav-" . ((int) ($i - 1));

                $paginationParams[$paramToReplace] = ($i-1)*$perPage+1;
                $listItems[$itemIndex] = array(
                    'title' => $i,
                    'link' => $this->view->url($urlIndex, $paginationParams),
                    'itemAttributes' => array(
					    'class' => 'pageNav pageNav-' . $itemIndex,
                     ),
                );

                if ( $showItemTitles ) {
                    $listItems[$itemIndex]['itemAttributes'] = array(
                        'title' => 'Results '.(($i-1)*$perPage+1).'-'.$titleEnd
                    );
                }

                if ( $linkAttributes ) {
                     $listItems[$itemIndex]['linkAttributes'] = $linkAttributes;
                }
            }

            if( ( $curPage != $lastPage-1 && $total ) || ( $alwaysShowPrevNext && $total )  ) {
                if ( $curPage == $lastPage-2 ) {
                    $titleEnd = $total;
                } else {
                    $titleEnd = ($curPage+1)*$perPage;
                }

                $paginationParams[$paramToReplace] = ($curPage)*$perPage+1;
                $listItems['next'] = array(
                    'title' => ( $showFirstLast ? $labels[2] : $labels[1] ),
                    'link' => $this->view->url($urlIndex, $paginationParams),
                    'itemAttributes' => array(
                        'class' => 'next',
                    ),
                );

                if ( $curPage == $lastPage-1 && $alwaysShowPrevNext ) {
                    unset($listItems['next']['link']);
                }

                if ( $showItemTitles ) {
                    $listItems['next']['itemAttributes']['title'] = 'Results '.(($curPage)*$perPage+1).'-'.$titleEnd;
                }

                if ( $linkAttributes ) {
                     $listItems['next']['linkAttributes'] = $linkAttributes;
                }
            }



            if ( $alwaysShowFirstLast && is_numeric( $total ) || ( $curPage != $lastPage && $showFirstLast && $lastPage > 1  && is_numeric( $total ) ) ) {
                
                if ( $total%$perPage == 0 )  {
                    $lastPageIndex = $total - ( $perPage ) + 1;    
                } else {
                    $lastPageIndex = $total - ( $total%$perPage ) + 1;    
                }

                
                $paginationParams[$paramToReplace] = $lastPageIndex;
                $listItems['last'] = array(
                    'title' => $labels[3],
                    'link' => $this->view->url($urlIndex, $paginationParams ),
                    'itemAttributes' => array(
                        'class' => 'lastitem',
                     ),
                );
                if ( $curPage == $lastPage-1 && $alwaysShowFirstLast ) {
                    unset($listItems['last']['link']);
                } 
                if ( $linkAttributes ) {
                     $listItems['last']['linkAttributes'] = $linkAttributes;
                }
            }




            if ( !$linkCurrent ) {
                unset($listItems["pageNav-" . $curPageIndex]['link']);
            }

            $finalItem = $perPage*$curPage;
            if (is_numeric($total) && $finalItem > $total) {
                $finalItem = $total;
            }

            if ( $total == 0 ) {
                if ( $objects ) {
                    $title = 'No '.$objects;
                } else {
                    $title = 'No Items';
                }
            } else {
                $title = $displayPrefix.' ';
                $title .=  ($perPage*($curPage-1))+1 .' - '. $finalItem.' '.$of.' '.$total.' '.$objects;
            }
        }

        $xhtml = '<div'.$this->view->htmlAttributes($containerAttributes).'>';
        if ( $showItemCounts ) {
            $xhtml .= '<span class="paginationTitle">'.$title.'</span>';
        }

		if ($ellipsisize) {
			$listItems = $this->view->ellipsisize("pageNav-" . $curPageIndex, $listItems, (int) ($rangeEnd - $rangeStart));
		}

        $listItemsCount = count($listItems);
        if ( $alwaysShowPrevNext ) {
            $listItemsCount = $listItemsCount-2;
        }
        if ( $alwaysShowFirstLast ) {
            $listItemsCount = $listItemsCount-2;
        }
        if ( $listItemsCount > 1 || $showPaginationIfOnePage ) {
            $xhtml .= $this->view->linkList($listItems, array( 'noLinkWrap' => 'span', 'selected' => $curPageIndex, 'attributes' => $listAttributes ));
        }
        $xhtml .= '</div>';

        return $xhtml;
    }

    public function setView(Zend_View_Interface $view)
    {
        $this->view = $view;
    }

}
