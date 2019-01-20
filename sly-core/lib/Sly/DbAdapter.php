<?php

/**
 * Base class for access to the database tables.
 *
 * @description This class is a one to one mapping to
 *              a table in the database.
 * @category Sly
 * @package Sly_DbAdapter
 */
class Sly_DbAdapter
{

   /**
     * @static
     * @var Sly_DbAdapter
     * @access protected
     */
    protected static $_instance = array();

   /**
     * @access protected
     * @var hash
     */
    protected $_dbConfig = array();
    
   /**
     * @access protected
     * @var MySql Connection
     */
    protected $_connection = null;
    
    /**
     * The databaseKey is used to determine what database to hit.  It must be
     * set before EVERY database action.  If null the database action will go
     * against all hosts.
     *
     * NOTE: This is only really used with the multi adapter, but we need
     * the functions here, because the Sly_Da classes calls these functions.
     * They will just get ignored for the normal adapter.
     *
     * @var integer
     */
    protected $_databaseKey = false;
    
    /**
     * @access public
     */
    public $_queryCount = 0;
    
   /**
     * @access public
     */
    public $_queries = array();
    
    // debug
    public $_queryStack = array();
    
    /**
     * @access public
     */
    public $_queryTime = 0;
    
    /**
     * Retrieves the adapter instance.
     *
     * @param hash $dbConfig
     * @return Sly_DbAdapter
     */
    public static function getInstance( $dbConfig )
    {
        $adapterKey = implode( '_', $dbConfig );
        
        if ( ! isset( self::$_instance[$adapterKey] ) ) {           
            self::$_instance[$adapterKey] = new self( $dbConfig );
        }

        return self::$_instance[$adapterKey];
    }

    public function __construct( $dbConfig )
    {
        $this->_dbConfig = $dbConfig;
    }

    public function getHost()
    {
        return $this->_dbConfig['host'];
    }
    
    public function connect( $newLink = false )
    {
        $start = microtime(true);
        $this->_connection = mysqli_connect( $this->_dbConfig{'host'},
                                            $this->_dbConfig{'username'},
                                            $this->_dbConfig{'password'},
                                            $newLink );
        $end = microtime(true);

        if ( ! $this->_connection ) {
            $errorMessage = "Sly_DbAdapter::connect unable to mysqli_connect to host: '".$this->_dbConfig{'host'}."' which took " . ($end-$start) . ' seconds. retrying...';
            error_log( $errorMessage );

            $this->_connection = mysqli_connect( $this->_dbConfig{'host'},
                                                $this->_dbConfig{'username'},
                                                $this->_dbConfig{'password'},
                                                $newLink );

            if ( ! $this->_connection ) {
                $errorMessage = "Sly_DbAdapter::connect with retry: failed to mysqli_connect to host: '".$this->_dbConfig{'host'}."'";
                error_log( $errorMessage );
            
                require_once 'Zend/Exception.php';
                throw new Zend_Exception( $errorMessage );
                return;
            }
            else {
                $errorMessage = "Sly_DbAdapter::connect with retry: success to mysqli_connect to host: '".$this->_dbConfig{'host'}."'";
                error_log( $errorMessage );
            }
        }        

        mysqli_select_db( $this->_connection, $this->_dbConfig{'dbname'} );

        // we no longer need this since the following NEEDS to be added to the mysql server configs
        // character_set_client=utf8
        // character_set_server=utf8
        //mysqli_query( $this->_conection, "SET NAMES 'utf8'" );        

        // this is so we can handle read/write of emojis.
        mysqli_set_charset( $this->_connection, 'utf8mb4' );
    }
            
    public function isConnected()
    {
        if ( $this->_connection ) {
            return true;
        }

        return false;
    }
         
    /**
     * Execute a query
     *
     * The optional connection will be used.  Otherwise the query will use 
     * $this->_connection
     *
     * @param string $sql
     * @param mysqli_connection
     * @return Result ID
     */     
    public function query( $sql, $connection = null )
    {
        //error_log( "sql: $sql" );
        
        if ( $connection === null ) {
            if ( ! $this->isConnected() ) {
                $this->connect();
            }
            
            $connection = $this->_connection;
        }

        if ( defined( 'SYSTEM_DEBUG_MODE' ) && SYSTEM_DEBUG_MODE ) {
            $this->_queryCount++;
            $this->_queries[] = $sql;
        
            if ( false && count( $this->_queryStack ) < 30 ) {
                // NOTE this is a very expensive opperation and should be pulled 
                // from production code
                $stack['query'] = $sql;
            
                ob_start(); 
                debug_print_backtrace(); 
                $trace = ob_get_contents(); 
                ob_end_clean();
            
                $stack['stack'] = $trace;
            
                $this->_queryStack[] = $stack;
            }
        
            $s = microtime(true);

            $result = mysqli_query( $connection, $sql );
            if ( ! $result ) {
                $errorMessage = "invalid query: $sql: " . mysqli_error( $connection );
                error_log( $errorMessage );
                require_once 'Zend/Exception.php';
                throw new Zend_Exception( $errorMessage );
            }
            $e = microtime(true);
            $this->_queryTime += ($e-$s);

            // do the describe as well
            //$describeResult = mysqli_query( $connection, "describe $sql" );
            //ob_start(); 
            //print "DESCRIBE<br>\n";
            //print "SQL: $sql<br>\n";
            //while( $row = mysqli_fetch_assoc( $describeResult ) ) {
            //    var_dump( $row );
            //    print "<br>\n";
            //}
            //$describe = ob_get_contents();
            //ob_end_clean();
            //$this->_queryStack[] = $describe;

        }
        else {
            
            $result = mysqli_query( $connection, $sql );
            if ( ! $result ) {
                
                // get the error code. if it is the 2006 (MySQL server has gone away)
                // then try the query again which should do the reconnect
                // http://dev.mysql.com/doc/refman/5.5/en/gone-away.html
                $errorId = mysqli_errno( $connection ); 

                if ( $errorId == 2006 ) {

                    $this->connect( true );
                    $connection = $this->_connection;

                    $result = mysqli_query( $connection, $sql );
                }

                if ( ! $result ) {
                    $errorMessage = "Sly_DbAdapter::query failed for sql '$sql' with mysqli_errno '". mysqli_errno( $connection ) . "' and mysqli_error '".mysqli_error( $connection )."'";
                    error_log( $errorMessage );
                    require_once 'Zend/Exception.php';
                    throw new Zend_Exception( $errorMessage );
                }
                    
            }
        }

        return $result;
    }

    public function fetchOne( $sql )
    {
        $result = $this->query( $sql );

        $row = mysqli_fetch_row( $result );
        if ( ! $row ) {
            return false;
        }
        return $row[0];
    }

    public function fetchRow( $sql )
    {
        $result = $this->query( $sql );

        $row = mysqli_fetch_assoc( $result );
        return $row;
    }
    
    public function fetchColumns( $sql )
    {
        $result = $this->query( $sql );

        $cols = array();
        while( $row = mysqli_fetch_row( $result ) ) {
            $cols[] = $row[0];
        }
        return $cols;
    }
    
    public function fetchAllColumns( $sql )
    {
        $result = $this->query( $sql );

        $cols = array();
        while( $row = mysqli_fetch_row( $result ) ) {
            $cols[] = $row;
        }
        return $cols;
    }

    public function fetchRows( $sql )
    {
        $result = $this->query( $sql );

        $rows = array();
        while( $row = mysqli_fetch_assoc( $result ) ) {
            $rows[] = $row;
        }
        return $rows;
    }

    /**
     * Fetch joined rows and break them up by table
     *
     * If you desire all the joined tables in the same row use fetchRows
     *
     * @param string $sql
     * @return hash
     */
    public function fetchJoinRows( $sql )
    {
        $result = $this->query( $sql );

        return $this->getTableResults( $result );
    }

    /**
     * Get and seperate results by table from a mysqlResultHandle
     *
     * @param mySqlResultHandle $result
     * @return array
     */
    public function getTableResults( $result ){
        $columnInfo = array();
        $tables = array();
        $rows = array();
        
        // determine what columns go with each table
        for( $i = 0; $i < mysqli_num_fields( $result ); $i++ ) {
            $meta = mysqli_fetch_field( $result, $i );
            $col['table'] = $meta->table;
            
            // insert in list of tables
            $table = $meta->table;
            if ( ! isset( $tables[$table] ) ) {
                $tables[$table] = false;
                $rows[$table] = array();
            }
            
            $col['name'] = $meta->name;
            $columnInfo[] = $col;
        }

        $columnCount = count( $columnInfo );
                        
        // break the results up by table        
        while( $resultRow = mysqli_fetch_array( $result ) ) {
            for( $i = 0; $i < $columnCount; $i++ ) {
                $table = $columnInfo[$i]['table'];
                $column = $columnInfo[$i]['name'];
                $value = $resultRow[$i];
                
                $row[$table][$column] = $value;
                
                // only add row for table if at least one non null value
                if ( $value !== null ) {
                    $tables[$table] = true;
                }
            }
            
            foreach( $tables as $table => $shouldSet ) {
                if ( $shouldSet ) {
                    $rows[$table][] = $row[$table];
                    $tables[$table] = false;
                }
            }
        }
        return $rows;
    }    
        
    public function fetchAssoc( $sql )
    {
        $result = $this->query( $sql );

        $data = array();
        while( $row = mysqli_fetch_assoc( $result ) ) {
            $tmp = array_values(array_slice($row,0,1));
            $data[$tmp[0]] = $row;
        }
        return $data;
    }
    
    public function delete( $sql )
    {
        $result = $this->query( $sql );

        return true;
    }

    public function insert( $sql )
    {
        $result = $this->query( $sql );

        return mysqli_insert_id( $this->_connection );
    }

    public function update( $sql )
    {
        $result = $this->query( $sql );

        return true;
    }

    public function replace( $sql )
    {
        $result = $this->query( $sql );

        return true;
    }

    public function quote( $string )
    {
        if ( ! $this->isConnected() ) {
            $this->connect();
        }
        
        return mysqli_real_escape_string( $this->_connection, $string );
    }

    /**
     * Start a database transaction
     *
     * @return boolean
     */
    public function startTransaction()
    {
        $this->query( 'set autocommit = 0' );
        $this->query( 'start transaction' );

        return true;
    }

    /**
     * End a database transaction
     *
     * Will commit by default
     *
     * @param boolean $save
     */
    public function endTransaction( $save = true )
    {
        if ( $save ) {
            $this->query( 'commit' );
        }
        else {
            $this->query( 'rollback' );
        }

        $this->query( 'set autocommit = 1' );

        return true;
    }

    /**
     * Get the database key
     *
     * @return integer
     */
    public function getDatabaseKey()
    {
        return $this->_databaseKey;
    }
    
    /**
     * Set the database key
     *
     * This MUST be run prior to ALL database actions if using the 
     * Sly_DbAdapter_Multi
     *
     * @param integer $databaseKey
     * @return void
     */
    public function setDatabaseKey( $databaseKey )
    {
        $this->_databaseKey = $databaseKey;
    }
}

?>
