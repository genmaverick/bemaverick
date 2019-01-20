<?php

use Google\Cloud\Storage\StorageClient;

class Sly_Service_Google_Storage
{

    public static function putFileContents( $fileContents, $filename, $options = null )
    {
        $systemConfig = Zend_Registry::get('systemConfig');

        $projectId = !empty( $options['projectId'] ) ?
            $options['projectId'] : $systemConfig->getSetting( 'GOOGLE_CLOUD_PROJECT_ID' );
        $keyFilePath = !empty( $options['keyFilePath'] ) ?
            $options['keyFilePath'] : $systemConfig->getSetting( 'GOOGLE_CLOUD_SERVICE_ACCOUNT_KEY_FILE_PATH' );
        $bucketName = !empty( $options['bucketName'] ) ?
            $options['bucketName'] : $systemConfig->getSetting( 'GOOGLE_CLOUD_BUCKET_NAME' );

        $storage = new StorageClient([
            'projectId' => $projectId,
            'keyFilePath' => $keyFilePath,
        ]);

        $bucket = $storage->bucket( $bucketName );

        $bucket->upload( $fileContents, array( 'name' => $filename ) );

        return true;
    }

    public static function getFileContents( $filename, $options = null )
    {
        $systemConfig = Zend_Registry::get('systemConfig');

        $projectId = !empty( $options['projectId'] ) ?
            $options['projectId'] : $systemConfig->getSetting( 'GOOGLE_CLOUD_PROJECT_ID' );
        $keyFilePath = !empty( $options['keyFilePath'] ) ?
            $options['keyFilePath'] : $systemConfig->getSetting( 'GOOGLE_CLOUD_SERVICE_ACCOUNT_KEY_FILE_PATH' );
        $bucketName = !empty( $options['bucketName'] ) ?
            $options['bucketName'] : $systemConfig->getSetting( 'GOOGLE_CLOUD_BUCKET_NAME' );

        $storage = new StorageClient([
            'projectId' => $projectId,
            'keyFilePath' => $keyFilePath,
        ]);

        $bucket = $storage->bucket( $bucketName );

        $object = $bucket->object( $filename );

        $stream = $object->downloadAsStream();

        return $stream->getContents();
    }

    public static function listFiles( $folder, $options = null )
    {

        $systemConfig = Zend_Registry::get( 'systemConfig' );

        $projectId = !empty( $options['projectId'] ) ?
            $options['projectId'] : $systemConfig->getSetting( 'GOOGLE_CLOUD_PROJECT_ID' );
        $keyFilePath = !empty( $options['keyFilePath'] ) ?
            $options['keyFilePath'] : $systemConfig->getSetting( 'GOOGLE_CLOUD_SERVICE_ACCOUNT_KEY_FILE_PATH' );
        $bucketName = !empty( $options['bucketName'] ) ?
            $options['bucketName'] : $systemConfig->getSetting( 'GOOGLE_CLOUD_BUCKET_NAME' );

        putenv( "GOOGLE_APPLICATION_CREDENTIALS=$keyFilePath" );

        $client = new Google_Client();
        $client->useApplicationDefaultCredentials();
        $client->addScope( Google_Service_Storage::DEVSTORAGE_READ_ONLY );

        $storage = new Google_Service_Storage( $client );

        $files = array();

        $listOptions = array(
            'prefix' => "$folder/",
            'fields' => 'items/name,items/size,items/timeCreated,nextPageToken'
        );

        $result = $storage->objects->listObjects( $bucketName, $listOptions );

        foreach ( $result->items as $item ) {
            $files[] = array(
                'name' => $item->name,
                'size' => $item->size,
                'timeCreated' => $item->timeCreated,
            );
        }

        while ( $result->nextPageToken ) {

            $listOptions['pageToken'] = $result->nextPageToken;

            $result = $storage->objects->listObjects( $bucketName, $listOptions );

            foreach ( $result->items as $item ) {
                $files[] = array(
                    'name' => $item->name,
                    'size' => $item->size,
                    'timeCreated' => $item->timeCreated,
                );
            }
        }

        return $files;
    }

}

?>
