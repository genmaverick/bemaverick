<?php

require_once( AWS_ROOT_DIR . '/aws-autoloader.php' );

use Aws\S3\S3Client;

class Sly_AmazonS3
{

    public static function putFileContents( $fileContents, $filename )
    {
        $systemConfig = Zend_Registry::get('systemConfig');

        $bucketName = $systemConfig->getAwsS3BucketName();
        $accessKey  = $systemConfig->getAwsAccessKey();
        $secretKey  = $systemConfig->getAwsSecretKey();

        $client = S3Client::factory( array(
            'key'    => $accessKey,
            'secret' => $secretKey,
        ));

        try {
            $client->putObject( array(
                'Bucket' => $bucketName,
                'Key'    => $filename,
                'Body'   => $fileContents,
                'ACL'    => 'public-read',
            ));
        } 
        catch ( S3Exception $e ) {
            error_log( "Sly_AmazonS3::putFileContents: There was an error uploading the file: $filename" );
            return false;
        }

        return true;
    }

    public static function getFileContents( $filename )
    {
        $systemConfig = Zend_Registry::get('systemConfig');

        $bucketName = $systemConfig->getAwsS3BucketName();
        $accessKey  = $systemConfig->getAwsAccessKey();
        $secretKey  = $systemConfig->getAwsSecretKey();

        $client = S3Client::factory( array(
            'key'    => $accessKey,
            'secret' => $secretKey,
        ));

        try {
            $result = $client->getObject( array(
                'Bucket' => $bucketName,
                'Key'    => $filename,
            ));
        }
        catch( S3Exception $e ) {
            error_log( "Sly_AmazonS3::getFileContents: There was an error getting the file: $filename" );
            return false;
        }

        return $result->get( 'Body' );
    }

}

?>
