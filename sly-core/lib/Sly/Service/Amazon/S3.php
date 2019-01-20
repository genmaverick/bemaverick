<?php

use Aws\S3\S3Client;

class Sly_Service_Amazon_S3
{

    /**
     * Upload the file contents to S3
     *
     * @param string $fileContents
     * @param string $filename
     * @param string $bucketName
     * @param hash $config
     * @return boolean
     */
    public static function putFileContents( $fileContents, $filename, $bucketName, $config )
    {
        $client = S3Client::factory( $config );

        try {
            $client->putObject(
                array(
                    'Bucket' => $bucketName,
                    'Key'    => $filename,
                    'Body'   => $fileContents,
                    'ACL'    => 'public-read',
                )
            );
        }
        catch ( S3Exception $e ) {
            error_log( "Sly_Service_Amazon_S3::putFileContents: There was an error uploading the file: $filename: " . $e->getMessage() );
            return false;
        }

        return true;
    }

    /**
     * Get the file contents from S3
     *
     * @param string $filename
     * @param string $bucketName
     * @param hash $config
     * @return string
     */
    public static function getFileContents( $filename, $bucketName, $config )
    {
        $client = S3Client::factory( $config );

        try {
            $result = $client->getObject(
                array(
                    'Bucket' => $bucketName,
                    'Key'    => $filename,
                )
            );
        }
        catch( S3Exception $e ) {
            error_log( "Sly_Service_Amazon_S3::getFileContents: There was an error getting the file: $filename: " . $e->getMessage() );
            return false;
        }

        return $result->get( 'Body' );
    }

    /**
     * Edit the ACL for a file in S3
     *
     * @param string $filename
     * @param string $bucketName
     * @param string $acl
     * @param hash $config
     * @return void
     */
    public static function editFileACL( $filename, $bucketName, $acl, $config )
    {
        $client = S3Client::factory( $config );

        try {

            $client->putObjectAcl(
                array(
                    'Bucket' => $bucketName,
                    'Key'    => $filename,
                    'ACL'    => $acl,
                )
            );
        }
        catch( S3Exception $e ) {
            error_log( "Sly_Service_Amazon_S3::editFileACL: There was an error editing the file: $filename: " . $e->getMessage() );
        }

    }

}

?>
