<?php
require_once( 'ApiTestBase.php' );

class ChallengeTest extends ApiBaseTest
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
        $this->accessToken = $accessTokenManager->createAccessToken( $app->getId(), 1, "write", false )["access_token"];
    }

    public function testAddResponse()
    {
        $url = "/v1/challenge/addresponse?challengeId=17&filename=06f8d59e3ec04cc62b2a1008fd8a9e3a.jpg&description=mydescription&responseType=image&tags=test1,test2&title=firstresponset&&skipTwilio=1&appKey={$this->appKey}";

        list( $response, $info ) = $this->getJsonWebservice( $url );

        $this->assertTrue( $info['http_code'] >= 200 && $info['http_code'] < 300, "Expected HTTP Code >= 200, < 300. Got: {$info['http_code']} -".json_encode($response) );
    }

    public function testAddResponseWithCoverImage()
    {
        $url = "/v1/challenge/addresponse?challengeId=17&filename=06f8d59e3ec04cc62b2a1008fd8a9e3a.jpg&description=mydescription&responseType=image&tags=test1,test2&title=firstresponset&&skipTwilio=1&coverImageFileName=06f8d59e3ec04cc62b2a1008fd8a9e3a.jpg&appKey={$this->appKey}";

        list( $response, $info ) = $this->getJsonWebservice( $url );

        $this->assertTrue( $info['http_code'] >= 200 && $info['http_code'] < 300, "Expected HTTP Code >= 200, < 300. Got: {$info['http_code']} -".json_encode($response) );
    }

    public function testVideoAddResponse()
    {
        $url = "/v1/challenge/addresponse?challengeId=17&filename=response-14-72b3eadb6729663353b7636e3ba1b921.MOV&description=myvideodescription&responseType=video&tags=test1,test2&title=videoresponseunittest&&skipTwilio=1&coverImageFileName=06f8d59e3ec04cc62b2a1008fd8a9e3a.jpg&appKey={$this->appKey}";

        list( $response, $info ) = $this->getJsonWebservice( $url );

        $this->assertTrue( $info['http_code'] >= 200 && $info['http_code'] < 300, "Expected HTTP Code >= 200, < 300. Got: {$info['http_code']} -".json_encode($response) );
    }

}
?>
