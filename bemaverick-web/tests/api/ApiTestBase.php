<?php
use PHPUnit\Framework\TestCase;

class ApiBaseTest extends TestCase
{
    protected $appKey = 'test_key';
    protected $accessToken;

    protected function getBaseUri()
    {
        $site = Zend_Registry::get( 'site' );
        $systemConfig = $site->getSystemConfig();

        $host = $systemConfig->getSetting( 'SYSTEM_HTTP_HOST' );
        $port = $systemConfig->getSetting( 'SYSTEM_HTTP_PORT' );
        return "http://$host" . ( $port ? ":$port" : '' );
    }
    /**
     * @param string $url
     * @return array
     */
    protected function getJsonWebservice( $url )
    {
        $header[] = 'Authorization: Bearer '.$this->accessToken;
        $s = curl_init();
        $fullUrl = $this->getBaseUri() . '/' . ltrim( $url, '/' );

        curl_setopt( $s, CURLOPT_USERAGENT, "PHPUnit" );
        curl_setopt( $s, CURLOPT_URL, $fullUrl );
        curl_setopt( $s, CURLOPT_TIMEOUT, 15 );
        curl_setopt( $s, CURLOPT_MAXREDIRS, 3 );
        curl_setopt( $s, CURLOPT_RETURNTRANSFER, true );
        curl_setopt( $s, CURLOPT_FOLLOWLOCATION, true );
        curl_setopt( $s, CURLOPT_HTTPHEADER, $header );
        $responseBody = curl_exec( $s );
        $info = curl_getinfo( $s );
        curl_close( $s );

        system( "tail -20 /var/log/apache2/error.log" );
        
        return array(json_decode( $responseBody, true ), $info );
    }

    public function testWarningSupression()
    {
        $this->assertTrue( true );
    }
}
?>
