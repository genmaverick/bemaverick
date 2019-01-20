<?php

class Sly_View_Helper_Table
{

    /**
     * @var Zend_View_Interface
     */
    public $view;

    /**
     * Generates a 'Table' element.
     *
     */
    public function Table(array $data, array $tableSettings = null)
    {


        $tableSettings['columnGroups'] = $this->_generateGroups($tableSettings);
        $tableSettings['columnOrder'] = $this->_generateColumnOrder($tableSettings['columnGroups']);

        if ( !isset($tableSettings['contentOnly']) || !$tableSettings['contentOnly'] ) {

            $tableSettings['tableAttributes'] = isset($tableSettings['tableAttributes']) ? $tableSettings['tableAttributes'] : array();
            $groupClass = !isset($tableSettings['dontUseGroups']) || $tableSettings['dontUseGroups'] != true ? 'hasGroups' : 'noGroups';
            if ( isset($tableSettings['rowIdPrefix']) ) {
                $tableSettings['tableAttributes'] = $this->view->formatUtil()->addItemToAttributes($tableSettings['tableAttributes'], 'class', 'tableType-'.$tableSettings['rowIdPrefix']);
            }
            $tableSettings['tableAttributes'] = $this->view->formatUtil()->addItemToAttributes($tableSettings['tableAttributes'], 'class', $groupClass );
            $tableAttributes = isset($tableSettings['tableAttributes']) ? $this->view->htmlAttributes($tableSettings['tableAttributes']) : '';
            $xhtml = '<table cellpadding="0" cellspacing="0"'.$tableAttributes.'>';
            $xhtml .= isset($tableSettings['caption']) ? '<caption>'.$tableSettings['caption'].'</caption>' : '';
            $xhtml .= $this->_generateHeaders($tableSettings);
            $xhtml .= $this->_generateContent($data,$tableSettings);
            $xhtml .= '</table>';
        } else {
            $xhtml = $this->_generateContent($data,$tableSettings);
        }

         return $xhtml;
    }

    protected function _generateHeaders($tableSettings) {

       $xhtml = '<thead>';
       if( !isset($tableSettings['dontUseGroups']) || $tableSettings['dontUseGroups'] != true) {
           $xhtml .= $this->_generateHeadersRow1($tableSettings);
       }
       $xhtml .= $this->_generateHeadersRow2($tableSettings);
       $xhtml .= '</thead>';
       return $xhtml;


    }


    protected function _generateHeadersRow1($tableSettings)
    {
        $columns = $tableSettings['columnGroups'];



        $xhtml = '<tr class="first">';

        $numColumns = count($columns);

        $columnCount = 0;
        $groupsWritten = array();
        foreach($columns as $key=>$column){
            $headerAttributes = array();
            $highlightColumn = null;
            if(is_array($column)){

                $groupIndex = explode('_',$key);
                if(count($column)>1) {
                    $headerAttributes['colspan'] = count($column);
                }
                $class = 'group '.$groupIndex[1];
                $firstGroupContent = '';
                if (! isset( $groupsWritten[$groupIndex[1]])){
                    $class.= ' firstgroup-'.$groupIndex[1];
                    $groupsWritten[$groupIndex[1]] = true;
                    $firstGroupContent = '<b></b>';
                }
                $title = isset($tableSettings['groups'][$groupIndex[1]][count($column)]) ? '<em>'.$firstGroupContent.'<span>'.$tableSettings['groups'][$groupIndex[1]][count($column)].'</span></em>' : '<em>'.$firstGroupContent.'<span>'.$tableSettings['groups'][$groupIndex[1]][0].'</span></em>';



                $headerAttributes['scope'] = 'colgroup';

            } else {


                $curColumnInfo = $tableSettings['columnInfo'][$column];
                if (isset($tableSettings['sort']) && isset($tableSettings['sort']['value']) && isset($curColumnInfo['sort'])) {
                    if ( $curColumnInfo['sort'] == $tableSettings['sort']['value'] ) {
                        $highlightColumn = $column;
                    }
                }
                $title = '&nbsp;';
                $class =  $curColumnInfo['className'];
            }

            $headerAttributes['class'] = $this->_getClass( $class, $this->view->getSemanticClass( $columnCount, $numColumns, $key, $highlightColumn, false, 'sorted') );

            $xhtml .= '<th'.$this->view->htmlAttributes($headerAttributes).'>'.$title.'</th>';
            $columnCount++;
        }

        $xhtml .= '</tr>';

        return $xhtml;
    }

    protected function _generateHeadersRow2($tableSettings)
    {
        $columns = $tableSettings['columnOrder'];

        $xhtml = '<tr class="last">';

        $numColumns = count($columns);

        $columnCount = 0;

        foreach($columns as $column){
            $highlightColumn = null;
            $sortUrl = null;
            $curColumnInfo = $tableSettings['columnInfo'][$column];
            //TODO - fix to use Sly_Url
            if (isset($tableSettings['sort']) && isset($tableSettings['sort']['value']) && isset($curColumnInfo['sort'])) {
                if ( $curColumnInfo['sort'] == $tableSettings['sort']['value'] ) {
                    $highlightColumn = $column;

                    if ( isset( $tableSettings['sort']['reverseUrl']) ) {
                        $sortUrl = $tableSettings['sort']['reverseUrl'];
                    }

                }
            }
            if (isset($tableSettings['sort']) && isset($tableSettings['sort']['url']) && isset($curColumnInfo['sort'])){
                $sortUrl = $sortUrl ? $sortUrl : $tableSettings['sort']['url'];
                $sortUrl = str_replace('_sort_',$curColumnInfo['sort'],$sortUrl);
                $hrefClass = '';
                if ( isset($tableSettings['sort']['isDynamic'] ) && $tableSettings['sort']['isDynamic']  ) {
                    $dynamicClass = isset($tableSettings['sort']['dynamicClass']) && $tableSettings['sort']['dynamicClass'] ? $tableSettings['sort']['dynamicClass'] : 'dynamic';
                    $hrefClass= ' class="'.$dynamicClass.'"';
                }
                $data = '';
                if (isset($tableSettings['sort']['dataAttributes'])) {
                  foreach ($tableSettings['sort']['dataAttributes'] as $dataAttributeName => $dataAttributeValue) {
                    $data .= $dataAttributeName.'="'.$dataAttributeValue.'"';
                  }
                }
                $title = '<a href="'.$sortUrl.'"'.$hrefClass.' '.$data.'>'.$curColumnInfo['title'].'</a>';
            } else {
                $title = '<span>'.$curColumnInfo['title'].'</span>';
            }
            $headerAttributes = array(
                'class' => $this->_getClass( $curColumnInfo['className'], $this->view->getSemanticClass( $columnCount, $numColumns, $column, $highlightColumn, false, 'sorted') ),
                'scope' => 'col',
            );
            $xhtml .= '<th'.$this->view->htmlAttributes($headerAttributes).'>'.$title.'</th>';
            $columnCount++;
        }

        $xhtml .= '</tr>';

        return $xhtml;
    }


    protected function _generateContent($data,$tableSettings)
    {
        $columns = $tableSettings['columnOrder'];
        $rows = $tableSettings['rows'];

        $rowCount = 0;
        $numRows = count($rows);
        $numColumns = count($columns);

        $highlightRows = isset( $tableSettings['highlightRows']) && isset( $tableSettings['highlightRows']['rows']) ? $tableSettings['highlightRows']['rows'] : null;
        $classedRows = (isset( $tableSettings['classedRows'] ) && sizeof($tableSettings['classedRows']) > 0) ? $tableSettings['classedRows'] : null;
        $insertedRows = isset( $tableSettings['insertedRows']) && isset( $tableSettings['insertedRows']) ? $tableSettings['insertedRows'] : null;
        $rowIdPrefix = isset( $tableSettings['rowIdPrefix'])  ? $tableSettings['rowIdPrefix'] : false;
        $xhtml = '';
        if ( !isset($tableSettings['contentOnly']) || !$tableSettings['contentOnly'] ) {
            $xhtml .= '<tbody>';
        }
        
        if (count($rows)) {

            foreach($rows as $rowNum => $rowIndex) {

                $rowEmpty = isset($data[$rowIndex]['_empty']) ? true : false;

                if($highlightRows && in_array($rowIndex,$highlightRows)) {
                    $highlightRow =  $rowIndex;
                    $highlightClass = isset($tableSettings['highlightRows']['class']) ? $tableSettings['highlightRows']['class'] : null;
                } else {
                    $highlightRow = null;
                    $highlightClass = null;
                }

                $classedRowClassesString = $this->getClassedRowClasses($classedRows, $rowIndex);

                $rowClassId = '';
                if ( $rowIdPrefix ) {
                    $rowClassId = $rowIdPrefix.'-'.$rowIndex;
                }

                $rowAttributes = array(
                    'class' => $this->_getClass( $rowClassId, $this->view->getSemanticClass( $rowCount, $numRows, $rowIndex, $highlightRow, true, $highlightClass))
                );
                if ( $rowEmpty ) {
                    $rowAttributes['class'] .= ' empty';
                }
                if ($classedRowClassesString) {
                    $rowAttributes['class'] .= ' ' . $classedRowClassesString;
                }

                $xhtml .= '<tr'.$this->view->htmlAttributes($rowAttributes).'>';

                $columnCount = 0;
                $colspan = 0;
                $rowspan = 0;
                foreach($columns as $column){
                    $highlightColumn  = null;
                    $curColumnInfo = $tableSettings['columnInfo'][$column];
                    if (is_array($data[$rowIndex][$column])) {
                        $content = (array_key_exists('content', $data[$rowIndex][$column])) ? $data[$rowIndex][$column]['content'] : '';
                    } else {
                        $content = $data[$rowIndex][$column];
                    }

                    if (is_array($data[$rowIndex][$column]) && (array_key_exists('colspan', $data[$rowIndex][$column]) &&
                                                                $data[$rowIndex][$column]['colspan'])) {
                        $colspan += $tableSettings['columnInfo'][$column]['colspan'];
                    } else if ($colspan) {
                        $colspan--;
                        continue;
                    }
                    if (isset($tableSettings['sort']) && isset($tableSettings['sort']['value']) && isset($curColumnInfo['sort'])) {
                        if ( $curColumnInfo['sort'] == $tableSettings['sort']['value'] ) {
                            $highlightColumn = $column;
                        }
                    }

                    if (isset($tableSettings['rowSpanInfo'][$column])) {

                        foreach ($tableSettings['rowSpanInfo'][$column] as $rowSpans) {
                            if ($rowNum == $rowSpans['start']) {
                                $rowspan = $rowSpans['end'] - $rowSpans['start'] + 1;
                                break;
                            } else if ($rowNum > $rowSpans['start'] && $rowNum <= $rowSpans['end'])
                            {
                                break 2; // don't print anything for this column
                            }
                        }
                    }

                    $headerAttributes = array(
                        'class' => $this->_getClass( $curColumnInfo['className'], $this->view->getSemanticClass( $columnCount, $numColumns, $column, $highlightColumn, false, 'sorted') ),
                    );
                    if ($colspan) {
                        $headerAttributes['colspan'] = $colspan;
                        $colspan--;
                    }
                    if ($rowspan) {
                        $headerAttributes['rowspan'] = $rowspan;
                    }
                    $xhtml .= '<td'.$this->view->htmlAttributes($headerAttributes).'>'.$content.'</td>';
                    $columnCount++;
                }
                $xhtml .= '</tr>';
                $rowCount++;

                $insertedRowXhtml = '';
                $insertBefore = false;
                if ( $insertedRows && isset( $insertedRows[$rowIndex] ) ) {
                    $insertedRow = $insertedRows[$rowIndex];
                    $insertBefore = isset($insertedRow['insertBefore']) ? $insertedRow['insertBefore'] : false ;
                    $rowClassId = '';
                    $delimiter = '';
                    if ( $rowIdPrefix ) {
                        $rowClassId = 'inserted'.$rowIdPrefix.'-'.$rowIndex;
                    }
                    if ( isset($insertedRow['class']) ) {
                        $insertedClass = $insertedRow['class'];
                    }

                    if ( $rowClassId && $insertedClass ) {
                        $delimiter = ' ';
                    }


                    $rowAttributes = array(
                        'class' => $rowClassId.$delimiter.$insertedClass
                    );
                    $cellAttributes = array(
                        'colspan' => $columnCount
                    );

                    $insertedRowXhtml = '<tr'.$this->view->htmlAttributes($rowAttributes).'>';
                    $insertedRowXhtml .= '<td'.$this->view->htmlAttributes($cellAttributes).'>';
                    $insertedRowXhtml .= $insertedRow['content'];
                    $insertedRowXhtml .= '</td>';
                    $insertedRowXhtml .= '</tr>';
                }

                if ( $insertedRowXhtml && !$insertBefore ) {
                    $xhtml .= $insertedRowXhtml;
                } else if ( $insertedRowXhtml ) {
                    $xhtml = $insertedRowXhtml.$xhtml;
                }
            }
        }
        if ( !isset($tableSettings['contentOnly']) || !$tableSettings['contentOnly'] ) {
            $xhtml .= '</tbody>';
        }
        return $xhtml;


    }


    /*
     * ret string
     * 
     * Array of hashes similar to highlight rows.
     *  - array(
     *        array('rows' => array( Row Indices ),
     *              'class' => Class Name to apply),
     *        ...
     *    );
     */
    public function getClassedRowClasses ( $classedRows, $rowIndex ) {
        $rowClasses = array();
        if ($classedRows) {
            foreach ($classedRows as $classedRowsConfig) {
                if ($classedRowsConfig['rows'] &&
                    in_array($rowIndex, $classedRowsConfig['rows'])) {
                    if (isset($classedRowsConfig['class'])) {
                        $rowClasses[] = $classedRowsConfig['class'];
                    }
                }
            }
        }
        return implode($rowClasses, ' ');
    }

    protected function _generateGroups( array $tableSettings ) {

        $groups = array();

        foreach($tableSettings['columns'] as $column) {
            $curColumnInfo = $tableSettings['columnInfo'][$column];

            if (isset( $curColumnInfo['group'])) {
                if (isset($groups['group_'.$curColumnInfo['group']])) {
                    $groups['group_'.$curColumnInfo['group']][] = $column;
                } else {
                    $groups['group_'.$curColumnInfo['group']] = array( $column );
                }

            } else {
              $groups[$column] = $column;
            }
        }


        return $groups;

    }

    protected function _generateColumnOrder( array $groups ) {

        $columnOrder = array();
        foreach( $groups as $key=>$column ) {
            if (is_array($column)) {
                foreach( $column as $col ) {
                    $columnOrder[] = $col;
                }
                continue;
            } else {
              $columnOrder[] = $key;
            }

        }

        return $columnOrder;

    }


    protected function _getClass($class = '', $semanticClass)
    {

        //addin semantic class to class item in itemAttributes
        if ( $semanticClass ) {
            if ($class) {
                $class .= " $semanticClass";
            } else {
                $class = $semanticClass;
            }
        }

        return $class;
    }

    public function setView(Zend_View_Interface $view)
    {
        $this->view = $view;
    }


}
