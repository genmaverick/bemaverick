<?php

use Google\Cloud\PubSub\PubSubClient;

class Sly_Service_Google_PubSub
{

    /**
     * Publish message to google pubsub
     *
     * @param string $topicName
     * @param hash $message
     * @param hash $options
     * @return void
     */
    public static function publishMessage( $topicName, $message, $options = null )
    {
        $systemConfig = Zend_Registry::get( 'systemConfig' );

        $projectId = ! empty( $options['projectId'] ) ?
            $options['projectId'] : $systemConfig->getSetting( 'GOOGLE_CLOUD_PROJECT_ID' );
        $keyFilePath = ! empty( $options['keyFilePath'] ) ?
            $options['keyFilePath'] : $systemConfig->getSetting( 'GOOGLE_CLOUD_SERVICE_ACCOUNT_KEY_FILE_PATH' );

        $config = array(
            'projectId' => $projectId,
            'keyFilePath' => $keyFilePath,
        );

        $pubSub = new PubSubClient( $config );

        try {
            $topic = $pubSub->topic( $topicName );

            $topic->publish( $message );
        }
        catch( Exception $e ) {
            error_log( "Sly_Service_Google_PubSub::publishMessage exception caught: " . $e->getMessage() );
        }

    }

}

?>
