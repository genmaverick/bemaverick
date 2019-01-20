<?php

// docs: http://msdn.microsoft.com/en-us/library/azure/dn223262.aspx

class Sly_Service_Microsoft_Azure_NotificationHub {

    const API_VERSION = "?api-version=2013-08";

    private $config;

    function __construct($connectionStrings, $hubPath = null)
    {
        if (!is_array($connectionStrings)) {
            $connectionStrings = array($hubPath => $connectionStrings);
        }
        
        foreach ($connectionStrings as $hubPath => $connectionString) {
            $config = array();
            $parts = explode(";", $connectionString);
            if (sizeof($parts) != 3) {
                throw new Exception("Error parsing connection string: " . $connectionString);
            }

            foreach ($parts as $part) {
                if (strpos($part, "Endpoint") === 0) {
                    $config['endpoint'] = "https" . substr($part, 11);
                } else if (strpos($part, "SharedAccessKeyName") === 0) {
                    $config['sasKeyName'] = substr($part, 20);
                } else if (strpos($part, "SharedAccessKey") === 0) {
                    $config['sasKeyValue'] = substr($part, 16);
                }
            }
            
            $this->config[$hubPath] = $config;
        }
    }

    private function generateSasToken( $uri, $config )
    {
        $targetUri = strtolower(rawurlencode(strtolower($uri)));

        $expires = time();
        $expiresInMins = 60;
        $expires = $expires + $expiresInMins * 60;
        $toSign = $targetUri . "\n" . $expires;

        $signature = rawurlencode(base64_encode(hash_hmac('sha256', $toSign, $config['sasKeyValue'], TRUE)));

        $token = "SharedAccessSignature sr=" . $targetUri . "&sig="
        . $signature . "&se=" . $expires . "&skn=" . $config['sasKeyName'];

        return $token;
    }
    
    private function initSendRequest( $body, $tagsOrTagExpression, $hubPath )
    {
        $config = $this->config[$hubPath];
        $tagExpression = is_array( $tagsOrTagExpression ) ? implode( " || ", $tagsOrTagExpression ) : $tagsOrTagExpression;

        // build uri
        $uri = $config['endpoint'] . $hubPath . "/messages" . self::API_VERSION;
        
        $request = curl_init($uri);
        
        $token = $this->generateSasToken($uri, $config);
        
        $headers =  array(
            'Authorization: '.$token,
            'Content-Type: application/json',
            'ServiceBusNotification-Format: template'
        );
        
        if ( $tagExpression ) {
            $headers[] = 'ServiceBusNotification-Tags: '.$tagExpression;
        }
        
        curl_setopt_array($request, array(
            CURLINFO_HEADER_OUT => true,
            CURLOPT_HEADER => true,
            CURLOPT_CONNECTTIMEOUT => 5,
            CURLOPT_TIMEOUT => 15,
            CURLOPT_POST => TRUE,
            CURLOPT_RETURNTRANSFER => TRUE,
            CURLOPT_SSL_VERIFYPEER => FALSE,
            CURLOPT_HTTPHEADER => $headers,
            CURLOPT_POSTFIELDS => $body
        ));
        
        return $request;
    }

    public function sendNotification( $payload, $tagsOrTagExpression, $hubPath = null )
    {
        if ( $hubPath == null ) {
            $keys = array_keys($this->config);
            $hubPath = array_shift($keys);
        }
        
        $payload = json_encode( $payload );
        
        $ch = $this->initSendRequest( $payload, $tagsOrTagExpression, $hubPath );
        
        // Send the request
        $response = curl_exec($ch);
        
        // Check for errors
        if ( $response === FALSE ) {
            throw new Exception(curl_error($ch));
        }
        
        $info = curl_getinfo($ch);
        
        if ( $info['http_code'] <> 201 ) {
            throw new Exception('Error sending notificaiton: '. $info['http_code'] . ' msg: ' . $response);
        }
        
        return $response;
    }
    
    /**
     * send notifications to a list of recipients
     *
     * @param $payload structure
     * @param $recipients array of $tag strings or array($tag, $hubPath) pairs
     * @param $concurrency integer
     */
    public function sendBatchNotification( $payload, $recipients, $concurrency = 1000 )
    {
        if (!count($recipients)) return;
        
        $keys = array_keys($this->config);
        $defaultHub = array_shift($keys);
        $payload = json_encode($payload);
        $sleep = 0;
        
        $urls = array();
        foreach ($this->config as $hubPath => $config) {
            $urls[$config['endpoint'] . $hubPath . '/messages' . self::API_VERSION] = $hubPath;
        }
        
        // group recipient tags into tag expressions (max 20 tags in OR expression)
        $groupedRecipients = array();
        $groups = array();
        foreach ($recipients as $r) {
            $hubPath = is_array($r) ? $r[1] : $defaultHub;
            $tag = is_array($r) ? $r[0] : $r;
            
            // don't create expressions with tags that are already expressions
            if (is_array($tag) || preg_match('/(&&)|(\|\|)|\(|\)/', $tag)) {
                $groupedRecipients[] = $r;
                continue;
            }
            
            if (isset($groups[$hubPath])) {
                if (count($groups[$hubPath][count($groups[$hubPath])-1]) < 20) {
                    $groups[$hubPath][count($groups[$hubPath])-1][] = $tag;
                } else {
                    $groups[$hubPath][] = array($tag);
                }
            } else {
                $groups[$hubPath] = array(array($tag));
            }
        }
        
        foreach ($groups as $hubPath => $hubGroups) {
            foreach ($hubGroups as $tags) {
                $groupedRecipients[] = array($tags, $hubPath);
            }
        }
        
        $recipients = $groupedRecipients;
        
        do {
            sleep($sleep);
            
            $failures = array();
            $multiHandle = curl_multi_init();
            
            for ($i = 0; $i < count($recipients) && $i < $concurrency; $i++) {
                $r = $recipients[$i];
                $tag = is_array($r) ? $r[0] : $r;
                $hubPath = is_array($r) ? $r[1] : $defaultHub;
                //error_log("Adding request: $tag $hubPath");
                curl_multi_add_handle($multiHandle, $this->initSendRequest($payload, $tag, $hubPath));
            }
            
            do {
                do {
                    $rv = curl_multi_exec($multiHandle, $active);
                } while ($rv == CURLM_CALL_MULTI_PERFORM);
                
                if ($rv != CURLM_OK) {
                    error_log('curl_multi_exec error: ' . curl_strerror($rv));
                    break;
                }
                
                curl_multi_select($multiHandle);
                
                while ($info = curl_multi_info_read($multiHandle)) {
                    $handle = $info['handle'];
                    $result = $info['result'];
                    $info = curl_getinfo($handle);
                    $status = $info['http_code'];
                    
                    if ($result != CURLE_OK || $status == 403) {
                        //error_log("Request error: $status");
                        if (preg_match('/^ServiceBusNotification-Tags: ([^\r\n]*)/m', $info['request_header'], $matches)) {
                            $failures[] = array($matches[1], $urls[$info['url']]);
                        }
                    } else if ($status != 201) {
                        error_log("Notification request error: \n" . curl_multi_getcontent($handle));
                    //} else if (preg_match('/^ServiceBusNotification-Tags: ([^\r\n]*)/m', $info['request_header'], $matches)) {
                    //    error_log('Request succeeded: '.$matches[1].' '.$urls[$info['url']]."\n".curl_multi_getcontent($handle));
                    //} else {
                    //    error_log('Request succeeded with request header: '.$info['request_header']);
                    }
                    
                    curl_multi_remove_handle($multiHandle, $handle);
                    curl_close($handle);
                    
                    if ($i < count($recipients)) {
                        $r = $recipients[$i++];
                        $tag = is_array($r) ? $r[0] : $r;
                        $hubPath = is_array($r) ? $r[1] : $defaultHub;
                        //error_log("Adding request: $tag $hubPath");
                        curl_multi_add_handle($multiHandle, $this->initSendRequest($payload, $tag, $hubPath));
                    }
                }
            } while ($active);
            
            curl_multi_close($multiHandle);
            
            $recipients = $failures;
            $concurrency = max(1, round($concurrency / 2));
            $sleep = max(1, $sleep * 2);
            
        } while (count($recipients));
    }

    public function registrations( $tag = null, $hubPath = null, $continuationToken = null )
    {
        if ( $hubPath == null ) {
            $keys = array_keys($this->config);
            $hubPath = array_shift($keys);
        }
        
        $config = $this->config[$hubPath];
        
        # build uri
        if ( $tag ) {
            $uri = $config['endpoint'] . $hubPath . "/tags/$tag/registrations" . self::API_VERSION;
        }
        else {
            $uri = $config['endpoint'] . $hubPath . "/registrations/" . self::API_VERSION;
        }

        if ( $continuationToken ) {
            $uri .= "&ContinuationToken=$continuationToken";
        }

        $ch = curl_init($uri);

        $headers = array(
            'Authorization: '.$this->generateSasToken($uri, $config),
            'Content-Type: application/xml;type=entry;charset=utf-8',
            'x-ms-version: 2013-08',
        );
        
        curl_setopt_array($ch, array(
            //CURLOPT_GET => TRUE,
            CURLOPT_RETURNTRANSFER => TRUE,
            CURLOPT_SSL_VERIFYPEER => FALSE,
            CURLOPT_HTTPHEADER => $headers,
            CURLOPT_HEADER => TRUE,
            CURLOPT_TIMEOUT => 10,
            CURLOPT_CONNECTTIMEOUT => 5,
        ));

        // Send the request
        $response = curl_exec($ch);

        // Check for errors
        if($response === FALSE){
            throw new Exception(curl_error($ch));
        }

        $info = curl_getinfo($ch);

        if ($info['http_code'] <> 200) {
            throw new Exception('Error sending notificaiton: '. $info['http_code'] . ' msg: ' . $response);
        }

        $header = substr($response, 0, $info['header_size']);
        $body = substr($response, $info['header_size']);

        $data = array(
            'header' => $header,
            'body' => $body,
        );

        return $data;
    }

    public function registration( $registrationId, $hubPath = null )
    {
        if ( $hubPath == null ) {
            $keys = array_keys($this->config);
            $hubPath = array_shift($keys);
        }
        
        $config = $this->config[$hubPath];
        
        # build uri
        $uri = $config['endpoint'] . $hubPath . "/registrations/$registrationId" . self::API_VERSION;

        $ch = curl_init($uri);

        $headers = array(
            'Authorization: '.$this->generateSasToken($uri, $config),
            'Content-Type: application/xml;type=entry;charset=utf-8',
            'x-ms-version: 2013-08',
        );
        
        curl_setopt_array($ch, array(
            //CURLOPT_GET => TRUE,
            CURLOPT_RETURNTRANSFER => TRUE,
            CURLOPT_SSL_VERIFYPEER => FALSE,
            CURLOPT_HTTPHEADER => $headers,
            CURLOPT_CONNECTTIMEOUT => 5,
            CURLOPT_TIMEOUT => 10,
        ));

        // Send the request
        $response = curl_exec($ch);

        // Check for errors
        if($response === FALSE){
            throw new Exception(curl_error($ch));
        }

        $info = curl_getinfo($ch);

        if ($info['http_code'] <> 200) {
            throw new Exception('Error sending notificaiton: '. $info['http_code'] . ' msg: ' . $response);
        }

        return $response;
    }

    public function updateRegistration( $registrationId, $type, $payloadData, $hubPath = null )
    {
        if ( $hubPath == null ) {
            $keys = array_keys($this->config);
            $hubPath = array_shift($keys);
        }
        
        $config = $this->config[$hubPath];
        $payload = null;
        
        if ( $type == 'GcmTemplateRegistrationDescription' ) {
            $payload = '<?xml version="1.0" encoding="utf-8"?>
<entry xmlns="http://www.w3.org/2005/Atom">
    <content type="application/xml">
        <GcmTemplateRegistrationDescription xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://schemas.microsoft.com/netservices/2010/10/servicebus/connect">
            <Tags>'.implode( ',', $payloadData['tags'] ).'</Tags>
            <GcmRegistrationId>'.$payloadData['gcmRegistrationId'].'</GcmRegistrationId>
            <BodyTemplate><![CDATA['.$payloadData['bodyTemplate'].']]></BodyTemplate>
        </GcmTemplateRegistrationDescription>
    </content>
</entry>';
        }
        else if ( $type == 'AppleTemplateRegistrationDescription' ) {
            $payload = '<?xml version="1.0" encoding="utf-8"?>
<entry xmlns="http://www.w3.org/2005/Atom">
    <content type="application/xml">
        <AppleTemplateRegistrationDescription xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://schemas.microsoft.com/netservices/2010/10/servicebus/connect">
            <Tags>'.implode( ',', $payloadData['tags'] ).'</Tags>
            <DeviceToken>'.$payloadData['deviceToken'].'</DeviceToken>
            <BodyTemplate><![CDATA[ '.$payloadData['bodyTemplate'].' ]]></BodyTemplate>
            <Expiry>'.$payloadData['expiry'].'</Expiry>
            <TemplateName>'.$payloadData['templateName'].'</TemplateName>
        </AppleTemplateRegistrationDescription>
    </content>
</entry>';
        }
        else if ( $type == 'AppleRegistrationDescription' ) {
            $payload = '<?xml version="1.0" encoding="utf-8"?>
<entry xmlns="http://www.w3.org/2005/Atom">
    <content type="application/xml">
        <AppleRegistrationDescription xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://schemas.microsoft.com/netservices/2010/10/servicebus/connect">
            <Tags>'.implode( ',', $payloadData['tags'] ).'</Tags>
            <DeviceToken>'.$payloadData['deviceToken'].'</DeviceToken>
        </AppleRegistrationDescription>
    </content>
</entry>';
        }
        else if ( $type == 'AdmTemplateRegistrationDescription' ) {
            $payload = '<?xml version="1.0" encoding="utf-8"?>
<entry xmlns="http://www.w3.org/2005/Atom">
    <content type="application/xml">
        <AdmTemplateRegistrationDescription xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://schemas.microsoft.com/netservices/2010/10/servicebus/connect">
            <Tags>'.implode( ',', $payloadData['tags'] ).'</Tags>
            <AdmRegistrationId>'.$payloadData['admRegistrationId'].'</AdmRegistrationId>
            <BodyTemplate><![CDATA['.$payloadData['bodyTemplate'].']]></BodyTemplate>
            <TemplateName>'.$payloadData['templateName'].'</TemplateName>
        </AdmTemplateRegistrationDescription>
    </content>
</entry>';
        }

        if ( ! $payload ) {
            error_log( "Sly_Service_Microsoft_Azure_NotificationHub::updateRegistration unknown type: $type" );
            return;
        }

        # build uri
        $uri = $config['endpoint'] . $hubPath . "/registrations/$registrationId" . self::API_VERSION;

        $ch = curl_init($uri);

        $headers = array(
            'Authorization: '.$this->generateSasToken($uri, $config),
            'Content-Type: application/atom+xml;type=entry;charset=utf-8',
            'x-ms-version: 2013-08',
            'If-Match: *',
        );

        curl_setopt_array($ch, array(
            CURLOPT_CUSTOMREQUEST => 'PUT',
            CURLOPT_RETURNTRANSFER => TRUE,
            CURLOPT_SSL_VERIFYPEER => FALSE,
            CURLOPT_HTTPHEADER => $headers,
            CURLOPT_POSTFIELDS => $payload,
            CURLOPT_CONNECTTIMEOUT => 5,
            CURLOPT_TIMEOUT => 10,
        ));

        // Send the request
        $response = curl_exec($ch);

        // Check for errors
        if($response === FALSE){
            throw new Exception(curl_error($ch));
        }

        $info = curl_getinfo($ch);

        if ($info['http_code'] <> 200) {
            throw new Exception('Error updating registration: '. $info['http_code'] . ' msg: ' . $response);
        }

        return $response;
    }

    public function deleteRegistration( $registrationId, $hubPath = null )
    {
        if ( $hubPath == null ) {
            $keys = array_keys($this->config);
            $hubPath = array_shift($keys);
        }
        
        $config = $this->config[$hubPath];
        
        # build uri
        $uri = $config['endpoint'] . $hubPath . "/registrations/$registrationId" . self::API_VERSION;

        $ch = curl_init($uri);

        $headers = array(
            'Authorization: ' . $this->generateSasToken($uri, $config),
            'Content-Type: application/atom+xml;type=entry;charset=utf-8',
            'If-Match: *',
            'x-ms-version: 2013-08',
        );

        curl_setopt_array($ch, array(
            CURLOPT_CUSTOMREQUEST => 'DELETE',
            CURLOPT_RETURNTRANSFER => TRUE,
            CURLOPT_SSL_VERIFYPEER => FALSE,
            CURLOPT_HTTPHEADER => $headers,
            CURLOPT_CONNECTTIMEOUT => 5,
            CURLOPT_TIMEOUT => 10,
        ));

        // Send the request
        $response = curl_exec($ch);

        // Check for errors
        if($response === FALSE){
            throw new Exception(curl_error($ch));
        }

        $info = curl_getinfo($ch);

        if ($info['http_code'] <> 200) {
            throw new Exception('Error deleting registration: '. $info['http_code'] . ' msg: ' . $response);
        }

        return $response;
    }

    public function createRegistration( $userPushNotificationTag, $type, $payloadData, $hubPath = null )
    {
        if ( $hubPath == null ) {
            $keys = array_keys($this->config);
            $hubPath = array_shift($keys);
        }
        
        $config = $this->config[$hubPath];
        $payload = null;

        $registrations = $this->registrations( $userPushNotificationTag );
        $xml = simplexml_load_string( $registrations['body'] );
        
        // Reg for Google
        if ( $type == 'GcmTemplateRegistrationDescription' ) {

            $azureRegId = null;
            foreach( $xml->entry as $entryXml ) {                
                $gcmRegistrationId = @$entryXml->content->GcmTemplateRegistrationDescription->GcmRegistrationId;
                if ( (string) $gcmRegistrationId === $payloadData['gcmRegistrationId']) {
                    $azureRegId = (string) @$entryXml->content->GcmTemplateRegistrationDescription->RegistrationId;
                    break;
                }
            }

            // found existing registration id, nothing new to create. return.
            if ( !is_null($azureRegId) ) {
                return $azureRegId;
            }

            $payload = '<?xml version="1.0" encoding="utf-8"?>
                <entry xmlns="http://www.w3.org/2005/Atom">
                    <content type="application/xml">
                        <GcmTemplateRegistrationDescription xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://schemas.microsoft.com/netservices/2010/10/servicebus/connect">
                            <Tags>'.implode( ',', $payloadData['tags'] ).'</Tags>
                            <GcmRegistrationId>'.$payloadData['gcmRegistrationId'].'</GcmRegistrationId>
                            <BodyTemplate><![CDATA['.$payloadData['bodyTemplate'].']]></BodyTemplate>
                            <TemplateName>'.$payloadData['templateName'].'</TemplateName>
                        </GcmTemplateRegistrationDescription>
                    </content>
                </entry>
            ';
        }
        else if ( $type == 'AppleTemplateRegistrationDescription' ) { // Reg for Apple with Template

            $azureRegId = null;
            foreach( $xml->entry as $entryXml ) {                
                $deviceToken = @$entryXml->content->AppleTemplateRegistrationDescription->DeviceToken;
                if ( (string) $deviceToken === $payloadData['deviceToken']) {
                    $azureRegId = (string) @$entryXml->content->AppleTemplateRegistrationDescription->RegistrationId;
                    // error_log('Found exising azure reg for apple: ' . $azureRegId );
                    break;
                }
            }

            // found existing registration id, nothing new to create. return.
            if ( !is_null($azureRegId) ) {
                return $azureRegId;
            }

            $payload = '<?xml version="1.0" encoding="utf-8"?>
                <entry xmlns="http://www.w3.org/2005/Atom">
                    <content type="application/xml">
                        <AppleTemplateRegistrationDescription xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://schemas.microsoft.com/netservices/2010/10/servicebus/connect">
                            <Tags>'.implode( ',', $payloadData['tags'] ).'</Tags>
                            <DeviceToken>'.$payloadData['deviceToken'].'</DeviceToken>
                            <BodyTemplate><![CDATA[ '.$payloadData['bodyTemplate'].' ]]></BodyTemplate>
                        </AppleTemplateRegistrationDescription>
                    </content>
                </entry>';

        }
        else if ( $type == 'AppleRegistrationDescription' ) { // Reg for Apple without a template

            $azureRegId = null;
            foreach( $xml->entry as $entryXml ) {                
                $deviceToken = @$entryXml->content->AppleRegistrationDescription->DeviceToken;
                if ( (string) $deviceToken === $payloadData['deviceToken']) {
                    $azureRegId = (string) @$entryXml->content->AppleRegistrationDescription->RegistrationId;
                    // error_log('Found exising azure reg ' . $azureRegId );
                    break;
                }
            }

            // found existing registration id, nothing new to create. return.
            if ( !is_null($azureRegId) ) {
                return $azureRegId;
            }

            $payload = '<?xml version="1.0" encoding="utf-8"?>
                <entry xmlns="http://www.w3.org/2005/Atom">
                    <content type="application/xml">
                        <AppleRegistrationDescription xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://schemas.microsoft.com/netservices/2010/10/servicebus/connect">
                            <Tags>'.implode( ',', $payloadData['tags'] ).'</Tags>
                            <DeviceToken>'.$payloadData['deviceToken'].'</DeviceToken>
                        </AppleRegistrationDescription>
                    </content>
                </entry>';
        }
        else if ( $type == 'AdmTemplateRegistrationDescription' ) {

            $azureRegId = null;
            foreach( $xml->entry as $entryXml ) {                
                $admRegistrationId = @$entryXml->content->AdmTemplateRegistrationDescription->AdmRegistrationId;
                if ( (string) $admRegistrationId === $payloadData['admRegistrationId']) {
                    $azureRegId = (string) @$entryXml->content->AdmTemplateRegistrationDescription->RegistrationId;
                    break;
                }
            }

            // found existing registration id, nothing new to create. return.
            if ( !is_null($azureRegId) ) {
                return $azureRegId;
            }

            $payload = '<?xml version="1.0" encoding="utf-8"?>
                <entry xmlns="http://www.w3.org/2005/Atom">
                    <content type="application/xml">
                        <AdmTemplateRegistrationDescription xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://schemas.microsoft.com/netservices/2010/10/servicebus/connect">
                            <Tags>'.implode( ',', $payloadData['tags'] ).'</Tags>
                            <AdmRegistrationId>'.$payloadData['admRegistrationId'].'</AdmRegistrationId>
                            <BodyTemplate><![CDATA['.$payloadData['bodyTemplate'].']]></BodyTemplate>
                            <TemplateName>'.$payloadData['templateName'].'</TemplateName>
                        </AdmTemplateRegistrationDescription>
                    </content>
                </entry>
            ';
        }

        if ( ! $payload ) {
            error_log( "Sly_Service_Microsoft_Azure_NotificationHub::updateRegistration unknown type: $type" );
            return;
        }

        # build uri
        $uri = $config['endpoint'] . $hubPath . "/registrations/" . self::API_VERSION;

        $ch = curl_init($uri);

        $headers = array(
            'Authorization: '.$this->generateSasToken($uri, $config),
            'Content-Type: application/atom+xml;type=entry;charset=utf-8',
            'x-ms-version: 2013-08',
            'If-Match: *',
        );

        curl_setopt_array($ch, array(
            CURLOPT_CUSTOMREQUEST => 'POST',
            CURLOPT_RETURNTRANSFER => TRUE,
            CURLOPT_SSL_VERIFYPEER => FALSE,
            CURLOPT_HTTPHEADER => $headers,
            CURLOPT_POSTFIELDS => $payload,
            CURLOPT_CONNECTTIMEOUT => 5,
            CURLOPT_TIMEOUT => 10,
        ));

        // Send the request
        $response = curl_exec($ch);

        // Check for errors
        if($response === FALSE){
            throw new Exception(curl_error($ch));
        }

        $info = curl_getinfo($ch);

        if ($info['http_code'] <> 200) {
            throw new Exception('Error creating registration: '. $info['http_code'] . ' msg: ' . $response);
        }

        // Parse response to and return the azure reg id.
        $responseXml = simplexml_load_string( $response );
        if ( $type == 'GcmTemplateRegistrationDescription' ) {
            return (string) @$responseXml->content->GcmTemplateRegistrationDescription->RegistrationId;
        }
        else if ( $type == 'AppleTemplateRegistrationDescription' ) {
            return (string) @$responseXml->content->AppleTemplateRegistrationDescription->RegistrationId;
        }
        else if ( $type == 'AppleRegistrationDescription' ) {
            return (string) @$responseXml->content->AppleRegistrationDescription->RegistrationId;
        }
        else if ( $type == 'AdmTemplateRegistrationDescription' ) {
            return (string) @$responseXml->content->AdmTemplateRegistrationDescription->RegistrationId;
        }
        else {
            return $response;
        }
    }
}

?>
