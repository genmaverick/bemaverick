<?php
require_once( 'ApiTestBase.php' );

class SiteTest extends ApiBaseTest
{
    protected function setUp()
    {
        $site = Zend_Registry::get( 'site' );
        $systemConfig = $site->getSystemConfig();
        $app = $site->getApp( $this->appKey );

        // Generate an access token
        $accessTokenManager = new Sly_OAuth_AccessTokenManager();
        $accessTokenManager->setTokenTTL( $app->getAuthTokenTTL() );
        $accessTokenManager->setAccessTokenSigningSecret( $systemConfig->getAccessTokenSigningSecret() );
        $this->accessToken = $accessTokenManager->createAccessToken( $app->getId(), null, "read", false )["access_token"];
    }

    public function testChallenges()
    {
        $url = "/v1/site/challenges?appKey={$this->appKey}";

        list( $response, $info ) = $this->getJsonWebservice( $url );

        $this->assertTrue( $info['http_code'] >= 200 && $info['http_code'] < 300, "Expected HTTP Code >= 200, < 300. Got: {$info['http_code']} -".json_encode($response) );
    }
}
?>
