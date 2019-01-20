<?php

require_once( SLY_ROOT_DIR . '/lib/Sly/Ftp/Exception.php' );

/**
 * Created by PhpStorm.
 * User: clintcarpenter
 * Date: 9/26/17
 * Time: 11:37 AM
 */
class Sly_Ftp
{
    const FTP_TIMEOUT = 10;
    const FTP_ERR_WAIT = 1; // 1 second wait before retry
    const FTP_ERR_ATTEMPTS = 10; // max number of attempt to connect to server
    const FTP_GET_ERR_ATTEMPTS = 10; // max number of consecutive tries to get a single file

    /**
     * Save the connection
     *
     * @var resource $_connId
     */
    private $_connId;

    /**
     * Data needed for connection
     *
     * @var array $_hostConfig
     */
    private $_hostConfig;

    /**
     * Logger for errors
     *
     * @var Sly_Log $_logger
     */
    private $_logger;

    /**
     * Default dir
     *
     * @var String $_dir
     */
    private $_dir;

    /**
     * Sly_Ftp constructor.
     *
     * @param array $hostConfig Must contain 'host', 'username', 'password' Optional: 'useFtps', 'port'
     * @param Sly_Log $logger
     * @param String $dir
     */
    public function __construct( $hostConfig, $logger, $dir = null )
    {
        $this->_hostConfig = $hostConfig;
        $this->_logger = $logger;
        $this->_dir = $dir;
        $this->_connId = null;
    }

    /**
     * Attempts to connect (or reconnect) to server.  Logs failed attempts.
     *
     * @throws Sly_Ftp_Exception
     * @return boolean
     */
    public function connect()
    {
        $hostConfig = $this->_hostConfig;
        $ftpHost = $hostConfig['host'];
        $ftpUsername = $hostConfig['username'];
        $ftpPassword = $hostConfig['password'];
        $ftpUseSecure = ( isset( $hostConfig['useFtps'] ) ) ? $hostConfig['useFtps'] : false;
        $ftpPort = ( isset( $hostConfig['port'] ) ) ? $hostConfig['port'] : 21;
        $dir = $this->_dir;
        $logger = $this->_logger;

        // Clear any previous connection
        if ( $this->_connId ) {
            ftp_close( $this->_connId );
            $this->_connId = null;
        }

        if ( !$ftpHost || !$ftpUsername || !$ftpPassword ) {
            $msg = "Insufficient host data.  Unable to connect! Host: $ftpHost Username: $ftpUsername Password: $ftpPassword";
            $logger->err( $msg );
            throw new Sly_Ftp_Exception( $msg );
        }

        $attemptCount = 0;
        $connId = null;

        // Attempt to get connection
        while ( ! $connId && $attemptCount <= self::FTP_ERR_ATTEMPTS ) {
            $attemptCount++;

            if ( $ftpUseSecure ) {
                $connId = ftp_ssl_connect( $ftpHost, $ftpPort, self::FTP_TIMEOUT );
            } else {
                $connId = ftp_connect( $ftpHost, $ftpPort, self::FTP_TIMEOUT );
            }

            if ( $connId === false ) {
                $logger->warn( "Failed connection attempt to $ftpHost:$ftpPort Attempts: $attemptCount" );
                sleep( self::FTP_ERR_WAIT );
            }
        }

        $success = false;
        $attemptCount = 0;

        // attempt to login
        while ( $connId && ! $success && $attemptCount <= self::FTP_ERR_ATTEMPTS ) {
            // login - we suppress the error and handle unsuccessful login with $success
            $success = @ftp_login( $connId, $ftpUsername, $ftpPassword );

            // set the connection mode to passive FTP
            ftp_pasv( $connId, true );

            // check connection
            if ( ! $success ) {
                $logger->warn( "Failed login attempt to $ftpHost for user $ftpUsername Attempts: $attemptCount" );
            }

            $attemptCount++;
        }

        if ( ! $connId || ! $success ) {
            $msg = "Exceeded connection Attempts for " . $ftpHost . " exiting!";
            $logger->err( $msg );
            throw new Sly_Ftp_Exception( $msg );
        } else {
            $logger->debug( "Connected to " . $ftpHost . " for user " . $ftpUsername );
        }

        if ( $dir ) {
            // change to directory
            $chDir = @ftp_chdir( $connId, $dir );

            if ( ! $chDir ) {
                $msg = "Cannot find directory: $dir";
                $logger->err( $msg );
                throw new Sly_Ftp_Exception( $msg );
            }
        }

        $this->_connId = $connId;
        return true;
    }

    /**
     * Disconnect from ftp server
     *
     * @return boolean
     */
    public function close() {
        $this->_logger->debug( "Disconnecting" );
        if ( $this->_connId ) {
            $success = ftp_close( $this->_connId );
        } else {
            $success = true;
        }
        $this->_connId = null;
        return $success;
    }

    /**
     * Get files matching pattern
     *
     * @param string $directory
     * @param string $pattern
     * @throws Sly_Ftp_Exception
     * @return array|false
     */
    public function getFileList( $directory, $pattern )
    {
        $logger = $this->_logger;

        $search = $directory;

        if ( $pattern ) {
            // If search exists, but doesn't end in / add it before adding the pattern
            if ( $search && substr_compare( $search, '/', -1 ) !== 0 ) {
                $search .= '/';
            }
            $search .= $pattern;
        }

        $logger->debug( "getFileList: directory: $directory pattern: $pattern search: $search" );

        // attempt to get list
        if ( ! $this->_connId ) {
            $this->connect();
        }

        $items = ftp_nlist( $this->_connId, $search );

        // Result will be false if directory does not exist so we do not want to retry and fatal error here.
        if ( $items === false ) {
            $logger->debug( "Unsuccessful attempt to getFileList directory: $directory pattern: $pattern" );
            // Close to force reconnect (just in case this was a connection issue)
            $this->close();
        }

        return $items;
    }

    /**
     * Gets a file
     *
     * @param string $localFile
     * @param string $remoteFile
     * @param int $mode
     * @throws Sly_Ftp_Exception
     * @return boolean
     */
    public function getFile( $localFile, $remoteFile, $mode )
    {
        $logger = $this->_logger;
        $success = false;
        $attemptCount = 0;

        $logger->debug( "getFile: localFile: $localFile remoteFile: $remoteFile" );

        // attempt to get list
        while ( ! $success && $attemptCount <= self::FTP_ERR_ATTEMPTS ) {
            if ( ! $this->_connId ) {
                $this->connect();
            }

            $success = ftp_get( $this->_connId, $localFile, $remoteFile, FTP_ASCII );

            if ( ! $success ) {
                $logger->warn( "Failed attempt to get file: $remoteFile" );
                // Close to force reconnect
                $this->close();

                // Delete file (suppress does not exist warning)
                @unlink( $localFile );
            }
        }

        if ( ! $success ) {
            $msg = "Exceeded Attempts get fileList: $remoteFile";
            $logger->err( $msg );

            // Delete file (suppress does not exist warning)
            @unlink( $localFile );

            throw new Sly_Ftp_Exception( $msg );
        }

        return $success;
    }
}