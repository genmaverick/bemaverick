<?php

require_once( SLY_ROOT_DIR . '/lib/Sly/DbAdapter.php' );

/**
 * Extension to a DB Adapter to allow for multiple database servers
 *
 * For round one the initial configuration information is for the database that
 * holds the key-host relationship.
 *
 * @category Sly
 * @package Sly_DbAdapter
 */
class Sly_DbAdapter_Multi extends Sly_DbAdapter
{

    /**
     * @var object
     */
    protected $_hostObject = null;
    
    /**
     * @var hash
     */
    protected $_multiDbConfig;
        
    /**
     * @var array
     */
    protected $_multiConnections = array();
    
    /**
     * @var array
     */
    protected $_allHosts = array();
    
    /**
     * @var array
     */
    protected $_lastHost = null;
    
    /**
     * Retrieves the adapter instance.
     *
     * @param hash $dbConfig
     * @return Sly_DbAdapter
     */
    public static function getInstance( $dbConfig, $hostObject )
    {
        $adapterKey = implode( '_', $dbConfig );
        
        if ( ! isset( self::$_instance[$adapterKey] ) ) {           
            self::$_instance[$adapterKey] = new self( $dbConfig, $hostObject );
        }

        return self::$_instance[$adapterKey];
    }
        
    /**
     * Creates the Sly_DbAdapter_Multi
     *
     * @param hash $multiDbConfig The database configuration information for the
     *                            multiple database hosts.  All information must
     *                            be the same except 'host'.
     * @param object $hostObject  An object that must support the functions:
     *                            getDatabaseHost( $id )
     *                            getDatabaseHosts()
     */
    public function __construct( $multiDbConfig, $hostObject )
    {
        $this->_multiDbConfig = $multiDbConfig;
        $this->_hostObject = $hostObject;
    }

    /**
     * See if there is a connection to a specific host
     *
     * @param string $host The host name
     * @return boolean
     */
    public function isHostConnected( $host )
    {
        if ( isset( $this->_multiConnections[$host] ) ) {
            return true;
        }

        return false;
    }

    /**
     * Connect to a specific host
     *
     * @param string $host Host name
     * @return void
     */
    public function connectHost( $host )
    {
        $start = microtime(true);

        $this->_multiConnections[$host] = mysqli_connect( $host,
                                                         $this->_multiDbConfig{'username'},
                                                         $this->_multiDbConfig{'password'} );

        $end = microtime(true);

        if ( ! $this->_multiConnections[$host] ) {
            $errorMessage = "Sly_DbAdapter_Multi::connectHost unable to mysqli_connect to host: '".$host."' which took " . ($end-$start) . ' seconds. retrying...';
            error_log( $errorMessage );

            $this->_multiConnections[$host] = mysqli_connect( $host,
                                                             $this->_multiDbConfig{'username'},
                                                             $this->_multiDbConfig{'password'} );

            if ( ! $this->_multiConnections[$host] ) {
                $errorMessage = "Sly_DbAdapter_Multi::connectHost with retry: failed to mysqli_connect to host: '".$host."'";
                error_log( $errorMessage );
            
                require_once 'Zend/Exception.php';
                throw new Zend_Exception( $errorMessage );
                return;
            }
            else {
                $errorMessage = "Sly_DbAdapter_Multi::connectHost with retry: success to mysqli_connect to host: '".$host."'";
                error_log( $errorMessage );
            }
        }
        
        mysqli_select_db( $this->_multiConnections[$host], $this->_multiDbConfig{'dbname'} );
        //mysqli_query( "SET NAMES 'utf8'" ); 
    }
    
    /**
     * Run a query against a specific host and return the resultId
     *
     * @param string $sql
     * @param string $host
     * @return mysqli_resultId
     */        
    public function queryHost( $sql, $host )
    {
        // get host's connection
        if ( ! $this->isHostConnected( $host ) ) {
            $this->connectHost( $host );
        }
        
        $connection = $this->_multiConnections[$host];
                
        // run query against host
        return parent::query( $sql, $connection );
    }

    /**
     * Run a query against all hosts and return an array of the resultIds
     *
     * @param string $sql
     * @return array
     */
    public function queryAllHosts( $sql )
    {
        $hosts = $this->getAllHosts();
        
        $resultIds = array();
        
        foreach( $hosts as $host ) {
            // get host's connection
            if ( ! $this->isHostConnected( $host ) ) {
                $this->connectHost( $host );
            }
            
            $connection = $this->_multiConnections[$host];
                    
            // run query against host
            $resultIds[] = parent::query( $sql, $connection );  
        }
        
        return $resultIds;
    }
              
    /**
     * Get the database host for a given query
     *
     * Return false if no database key is set.
     * 
     * @return string/boolean The host name or false if no specific league
     */
    public function getHost()
    {
        if ( $this->_databaseKey === false ) {
            $this->unsupportedError( '', 'databaseKey must be set to key or null' );
        }
        
        if ( $this->_databaseKey === null ) {
            $this->_databaseKey = false;
            return false;
        }
        
        $host = $this->_hostObject->getDatabaseHost( $this->_databaseKey );
        
        // clear the databaseKey to force reset next connection
        $this->_databaseKey = false;
        
        $this->_lastHost = $host;
        
        return $host;
    }
    
    /**
     * Get a default host
     *
     * Will attempt to use _lastHost first.  Then _databaseKey's host (without 
     * clearing).  Finally use a random host from all hosts.
     *
     * @return string
     */
    public function getDefaultHost()
    {
        if ( $this->_lastHost ) {
            return $this->_lastHost;
        }
        
        if ( $this->_databaseKey !== false ) {
            $databaseKey = $this->_databaseKey;
            $host = $this->getHost();
            
            // restore databaseKey for the 'real' query
            $this->_databaseKey = $databaseKey;
            
            if ( $host ) {
                $this->_lastHost = $host;
                return $host;
            }
        }

        // for now we want to know if we are getting here
        error_log( "DbAdapter_Multi::getDefaultHost: falling to random host" );
        
        $hosts = $this->getAllHosts();
        $host = $hosts[rand(0,(count($hosts)-1))];
        $this->_lastHost = $host;
        return $host;
        
        //return $this->_multiDbConfig['host'];
    }
    
    /**
     * Get all of the database hosts for queries against all
     *
     * This function will need to be overloaded for a specific implementation.
     * For development the Fantasy_Full_Leagues logic is here.
     *
     * @return array
     */
    public function getAllHosts()
    {
        if ( count( $this->_allHosts ) > 0 ) {
            return $this->_allHosts;
        }
        
        $this->_allHosts = $this->_hostObject->getDatabaseHosts();
        
        return $this->_allHosts;
    }      

    /**
     * General error message for unsupported queries
     *
     * @param string $sql
     * @param string $msg
     * @return void
     */
    public function unsupportedError( $sql, $msg = null )
    {
        if ( $msg == null ) {
            $msg = 'Unsupported Multi Database Query';
        }
        
        $msg .= " SQL: $sql";
        error_log( $msg );
        require_once 'Zend/Exception.php';
        throw new Zend_Exception( $msg );
    }
            
    public function fetchOne( $sql )
    {
        if ( $host = $this->getHost() ) {
            
            $result = $this->queryHost( $sql, $host );
    
            $row = mysqli_fetch_row( $result );
            if ( ! $row ) {
                return false;
            }
            return $row[0];
        }
        
        // multi host
        
        // determine if the one value is an agregation        
        if ( ! preg_match( '/SELECT\s*(.*?)\s*\(\s*(.*?)\s*\)/i', $sql, $matches ) ) {
            $this->unsupportedError( $sql, 'Must use agregation or databaseKey with fetchOne' );
        }
        
        $agregator = $matches[1];
        
        switch( $agregator ) {
            case 'count':
                $results = $this->queryAllHosts( $sql );
                
                $totalCount = 0;
                
                foreach( $results as $result ) {
                    $row = mysqli_fetch_row( $result );
                    if ( $row ) {
                        $totalCount += $row[0];
                    }
                }
                
                return $totalCount;
            case 'max':
                $results = $this->queryAllHosts( $sql );
                
                $max = 0;
                
                foreach( $results as $result ) {
                    $row = mysqli_fetch_row( $result );
                    if ( $row ) {
                        if ( $row[0] > $max ) {
                            $max = $row[0];
                        }
                    }
                }
                
                return $max;
            case 'average':
                // not a TRUE average.  Just averages the averages of the servers
                $results = $this->queryAllHosts( $sql );
                
                $total = 0;
                $count = 0;
                
                foreach( $results as $result ) {
                    $row = mysqli_fetch_row( $result );
                    if ( $row ) {
                        $total += $row[0];
                        $count++;
                    }
                }
                
                return $total / $count;
            default:
                $this->unsupportedError( $sql, 'Unsupported agregator on fetchOne' );
        }
    }

    public function fetchRow( $sql )
    {
        if ( $host = $this->getHost() ) {
            $result = $this->queryHost( $sql, $host );
    
            $row = mysqli_fetch_assoc( $result );
            return $row;
        }
        
        // multi host
        $this->unsupportedError( $sql );
    }
    
    public function fetchColumns( $sql )
    {
        if ( $host = $this->getHost() ) {
            $result = $this->queryHost( $sql, $host );
    
            $cols = array();
            while( $row = mysqli_fetch_row( $result ) ) {
                $cols[] = $row[0];
            }
            return $cols;
        }
                
        // multi host
        $results = $this->queryAllHosts( $sql );
        
        $cols = array();
        
        foreach ( $results as $result ) {
            while( $row = mysqli_fetch_row( $result ) ) {
                $cols[] = $row[0];
            }
        }
        
        return $cols;
        
    }
    
    public function fetchAllColumns( $sql )
    {
        if ( $host = $this->getHost() ) {
            $result = $this->queryHost( $sql, $host );
    
            $cols = array();
            while( $row = mysqli_fetch_row( $result ) ) {
                $cols[] = $row;
            }
            return $cols;
        }
                
        // multi host
        $results = $this->queryAllHosts( $sql );
        
        $cols = array();
        
        foreach ( $results as $result ) {
            while( $row = mysqli_fetch_row( $result ) ) {
                $cols[] = $row;
            }
        }
        
        return $cols;
        
    }

    public function fetchRows( $sql )
    {
        if ( $host = $this->getHost() ) {
            return($this->fetchRowsHost( $sql, $host ));
        }
                
        // multi host
        $results = $this->queryAllHosts( $sql );
        
        $rows = array();
        
        foreach ( $results as $result ) {
            while( $row = mysqli_fetch_assoc( $result ) ) {
                $rows[] = $row;
            }
        }
        
        return $rows;
    }

    public function fetchRowsHost( $sql, $host )
    {
        $result = $this->queryHost( $sql, $host );
    
        $rows = array();
        while( $row = mysqli_fetch_assoc( $result ) ) {
            $rows[] = $row;
        }
        return $rows;
    }

    public function fetchJoinRows( $sql )
    {
        if ( $host = $this->getHost() ) {
            $result = $this->queryHost( $sql, $host );
    
            return $this->getTableResults( $result );
        }
                
        // multi host
        $results = $this->queryAllHosts( $sql );
        
        return $this->getTableResults( $result );
    }

    public function fetchAssoc( $sql )
    {
        if ( $host = $this->getHost() ) {
            $result = $this->queryHost( $sql, $host );
    
            $data = array();
            while( $row = mysqli_fetch_assoc( $result ) ) {
                $tmp = array_values(array_slice($row,0,1));
                $data[$tmp[0]] = $row;
            }
            return $data;
        }
                
        // multi host
        $results = $this->queryAllHosts( $sql );
        
        $data = array();
        
        foreach ( $results as $result ) {
            while( $row = mysqli_fetch_assoc( $result ) ) {
                $tmp = array_values(array_slice($row,0,1));
                $data[$tmp[0]] = $row;
            }
        }
        
        return $data;
    }
    
    public function delete( $sql )
    {
        if ( $host = $this->getHost() ) {
            $result = $this->queryHost( $sql, $host );
    
            return true;
        }

        // multi host
        //$this->unsupportedError( $sql, 'DatabaseKey must be set for delete' );

        $retVal = $this->queryAllHosts( $sql ); 

        return $retVal;
    }

    public function insert( $sql )
    {
        if ( $host = $this->getHost() ) {
            $result = $this->queryHost( $sql, $host );
    
            return mysqli_insert_id( $this->_multiConnections[$host] );
        }
                
        // multi host
        $this->unsupportedError( $sql, 'DatabaseKey must be set for insert' );
    }

    public function update( $sql )
    {
        if ( $host = $this->getHost() ) {
            $result = $this->queryHost( $sql, $host );
    
            return true;
        }
                
        // multi host
        $this->unsupportedError( $sql, 'DatabaseKey must be set for update' );
    }

    public function replace( $sql )
    {
        if ( $host = $this->getHost() ) {
            $result = $this->queryHost( $sql, $host );
    
            return true;
        }
                
        // multi host
        $this->unsupportedError( $sql, 'DatabaseKey must be set for replace' );
    }

    public function query( $sql, $connection = null )
    {
        if ( $host = $this->getHost() ) {
            $result = $this->queryHost( $sql, $host );
    
            return true;
        }
                
        // multi host
        $this->unsupportedError( $sql, 'DatabaseKey must be set for query' );
    }
    
    /**
     * Escape a string
     *
     * This function ALWAYS uses the masterDbAdapter.  If the character sets are
     * ever different from the multi databases then it must be rewrote.
     *
     * @param string $string
     * @return string
     */
    public function quote( $string )
    {
        $host = $this->getDefaultHost();
        
        // get host's connection
        if ( ! $this->isHostConnected( $host ) ) {
            $this->connectHost( $host );
        }
        
        return mysqli_real_escape_string( $this->_multiConnections[$host], $string );        
    }
    
    /**
     * Start a database transaction
     *
     * @param $databaseKey Required for multi DbAdapter
     * @return boolean
     */
    public function startTransaction()
    {
        if ( $host = $this->getHost() ) {
            $this->queryHost( 'set autocommit = 0', $host );
            $this->queryHost( 'start transaction', $host );
    
            return true;
        }
        
        // multi host
        $this->unsupportedError( 'start transaction', 'databaseKey must be set for startTransaction' );        
    }

    /**
     * End a database transaction
     *
     * Will commit by default
     *
     * @param boolean $save
     * @param integer $databaseKey Required for multi DbAdapter
     */
    public function endTransaction( $save = true )
    {
        if ( $host = $this->getHost() ) {
            if ( $save ) {
                $this->queryHost( 'commit', $host );
            }
            else {
                $this->queryHost( 'rollback', $host );
            }
            $this->queryHost( 'set autocommit = 1', $host );
    
            return true;
        }
        
        // multi host
        $this->unsupportedError( 'commit', 'databaseKey must be set for endTransaction' );        
    }

}

?>
