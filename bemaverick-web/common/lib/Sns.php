<?php
use Aws\Sns\SnsClient;
/**
 * Class sns for the entire site
 *
 */
class BeMaverick_Sns
{
    const SNS_PUBLISH_ACTION_CREATE     = 'CREATE';
    const SNS_PUBLISH_ACTION_UPDATE     = 'UPDATE';
    const SNS_PUBLISH_ACTION_DELETE     = 'DELETE';

    /**
     * Send content update info to publish sns
     *
     * @param BeMaverick_Site $site
     * @param string $contentType
     * @param integer $contentId
     * @param string $action
     * @param array $contentData
     *
     * @return void
     */
    public static function publish( $site, $contentType, $contentId, $action, $data )
    {
        $systemConfig = $site->getSystemConfig();
        $amazonConfig = $site->getAmazonConfig();
        $topicARN = $systemConfig->getSetting( 'AWS_SNS_TOPIC_CHANGE_CONTENT' );

        $body = array(
            'contentType'   => $contentType,
            'contentId'  => $contentId,
            'action'  => $action,
            'data'  => $data,
        );

        try {
            $client = SnsClient::factory( $amazonConfig );
            $messageArray =[
                'TopicArn' => $topicARN,
                'Message' => json_encode( $body, JSON_UNESCAPED_SLASHES ),
            ];

            $snsResponse = $client->publish( $messageArray );

            return "Success";
            // error_log( print_r("SNS response for publish".json_encode( $snsResponse ), true) );
        }
        catch( Zend_Exception $e ) {
            error_log( "BeMaverick_Sns::publish::Exception found: " . $e->getMessage() );
            return "Error: could not publish change to SNS";
        }
    }

    /**
     * Send content update info to events sns
     *
     * @param BeMaverick_Site $site
     * @param string $eventType
     * @param string $userId
     * @param string $contentType
     * @param integer $contentId
     * @param array $data
     *
     * @return void
     */
    public static function publishEvent( $site, $eventType, $contentType, $contentId, $userId, $data )
    {
        $systemConfig = $site->getSystemConfig();
        $amazonConfig = $site->getAmazonConfig();
        $topicARN = $systemConfig->getSetting( 'AWS_SNS_TOPIC_EVENTS' );

        $body = array(
            'eventType' => $eventType,
            'userId'  => $userId,
            'contentType'   => $contentType,
            'contentId'  => $contentId,
            'data'  => $data,
        );

        try {
            $client = SnsClient::factory( $amazonConfig );
            $messageArray =[
                'TopicArn' => $topicARN,
                'Message' => json_encode( $body, JSON_UNESCAPED_SLASHES ),
            ];

            $snsResponse = $client->publish( $messageArray );

            return "Success";
            // error_log( print_r("SNS response for publish".json_encode( $snsResponse ), true) );
        }
        catch( Zend_Exception $e ) {
            error_log( "BeMaverick_Sns::publish::Exception found: " . $e->getMessage() );
            return "Error: could not publish change to SNS";
        }
    }
}

?>
