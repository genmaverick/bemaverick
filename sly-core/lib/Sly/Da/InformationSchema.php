<?php

require_once( SLY_ROOT_DIR . '/lib/Sly/Da.php' );

class Sly_Da_InformationSchema extends Sly_Da
{

    /**
     * @static
     * @var Sly_Da_InformationSchema
     * @access protected
     */    
    protected static $_instance = null;

    /**
     * @var string
     * @access protected
     */
    protected $_database = 'information_schema';

    /**
     * @var string
     * @access protected
     */
    protected $_table = 'columns';

    /**
     * @var array
     * @access protected
     */
    protected $_primary = array('table_schema', 'table_name');

    /**
     * Retrieves the da instance.
     *
     * @return Sly_Da_InformationSchema
     */
    public function getInstance()
    {
        if (is_null(self::$_instance)) {

            self::$_instance = new self();

            $systemConfig = Zend_Registry::get('systemConfig');
            $dbConfig = $systemConfig->getDatabaseConfig();
        }

        return self::$_instance;
    }

    /**
     * Retrieves the column names for the table [tableName] in [databaseName].
     *
     * @return Sly_Da_InformationSchema
     */
    public function getColumns($databaseName, $tableName = null )
    {
        $select = array( 'COLUMN_NAME', 'COLUMN_KEY', 'TABLE_NAME' );

        $where = array();
        $where[] = "TABLE_SCHEMA = '$databaseName'";

        if ( $tableName ) {        
            $where[] = "TABLE_NAME = '$tableName'";
        }

        $sql = $this->createSqlStatement( $select, $where );
        
        return $this->fetchRows($sql);
    }

}

?>