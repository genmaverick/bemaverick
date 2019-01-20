<?php
$USER = preg_match( '/^\/home\/([^\/]+)\//', getcwd(), $matches ) ? $matches[1] : false;

// these are expected to be defines
if ( ! defined( 'BEMAVERICK_DEFINES' ) ) {

    define( 'BEMAVERICK_DEFINES', true );

    // the debug setting is used in places that do not allways have access to
    // system config so it needs to be a define
    define( 'SYSTEM_DEBUG_MODE',    true );
}

$settings = array(

    // common settings for all sites
    'common' => array(

        // standard configs
        'SYSTEM_SITE_ID'                   => 1,
        'SYSTEM_ENVIRONMENT'               => 'devel',
        'SYSTEM_DEBUG_MODE'                => false,
        'SYSTEM_ERROR_EMAIL_ADDRESS'       => "shawn@slytrunk.com",
        'SYSTEM_ADMIN_EMAIL_ADDRESSES'     => array( "shawn@slytrunk.com" ),

        // http hosts
        'SYSTEM_WEBSITE_HTTP_HOST'         => "$USER-website-bemaverick.dev.slytrunk.com",

        // http caching
        'SYSTEM_HTTP_CACHE_TTL'            => 0,
        'SYSTEM_MERGE_FILES_MISS_TTL'      => 5,
        'SYSTEM_API_HTTP_CACHE_TTL'        => 0,

        // date configs
        'SYSTEM_CURRENT_DATE'              => false,
        'SYSTEM_CURRENT_TIME'              => false,

        // cache configs
        'SYSTEM_CACHE_TYPE'                => 'redis',
        'SYSTEM_REDIS_HOSTS'               => array( 'localhost:6379' ),

        // frontend configs
        'SYSTEM_LESS_ENABLED'              => true,

        // salts
        'SYSTEM_RESET_PASSWORD_SALT'       => 'reset_password_salt',
        'SYSTEM_VERIFY_ACCOUNT_SALT'       => 'very_account_salt',

        // cookie configs
        'SYSTEM_COOKIE_SALT'               => '6efa2c9d1l1i1e8c6',
        'SYSTEM_COOKIE_DOMAIN'             => 'dev.slytrunk.com',

        // translations configs
        'SYSTEM_TRANSLATION_FILE'          => BEMAVERICK_COMMON_ROOT_DIR . '/translations/strings.tmx',

        // image configs
        'SYSTEM_IMAGE_SALT'                => '7748ea6efa2c9d1l1i1e8c63f',
        'SYSTEM_IMAGE_HOST'                => "$USER-api-bemaverick.dev.slytrunk.com",
        'SYSTEM_IMAGE_PROTOCOL'            => 'https',
        'SYSTEM_IMAGE_COMPRESSION_QUALITY' => 90,
        'SYSTEM_ASSETS_DIR'                => '/home/shawnr/assets',

        // security configs
        'SYSTEM_CSRF_HOST'                 => "dev.slytrunk.com",

        // random configs
        'SYSTEM_NUM_USERS_WITH_RESPONSE_TO_CHALLENGE' => 3,
        'SYSTEM_UPLOAD_FILE_SIZE_MAX_MB'   => null,

        // google api
        'GOOGLE_CLOUD_PROJECT_ID'          => '',
        'GOOGLE_CLOUD_BUCKET_NAME'         => '',
        'GOOGLE_CLOUD_SERVICE_ACCOUNT_KEY_FILE_PATH' => '',

        // oauth authentication signing key
        'OAUTH_ACCESS_TOKEN_SIGNING_SECRET' => 'foobar',

        //deep link for the app
        'APP_DEEPLINK'  => 'https://bemaverick.test-app.link/YqtwHAyMOM',
        'APPLE_APPSTORE_APP_ID' => '1301478918',

        // aws configs
        'AWS_S3_VIDEO_INPUT_BUCKET_NAME'     => 'bemaverick-input-videos',
        'AWS_S3_VIDEO_OUTPUT_BUCKET_NAME'    => 'bemaverick-output-videos',
        'AWS_S3_VIDEO_THUMBNAIL_BUCKET_NAME' => 'bemaverick-output-videos-thumbnails',
        'AWS_S3_IMAGE_BUCKET_NAME'           => 'bemaverick-images',
        'AWS_VIDEO_TRANSCODER_ENABLED'       => true,
        'AWS_VIDEO_TRANSCODER_HLS_ENABLED'   => true,
        'AWS_VIDEO_TRANSCODER_PIPELINE_ID'   => '1520280703621-mlywxt',
        'AWS_VIDEO_TRANSCODER_CHALLENGE_PRESET_ID'  => '1508263294700-q95dez',
        'AWS_VIDEO_TRANSCODER_RESPONSE_PRESET_ID'   => '1508785183480-kw5qwt',
        'AWS_REGION'                         => 'us-east-1',
        'AWS_ACCESS_KEY_ID'                  => 'AKIAILVXMLMU2X62NCSQ',
        'AWS_ACCESS_KEY_SECRET'              => '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',
        'AWS_VIDEO_CLOUD_FRONT_URI'          => 'https://d32424o5gwcij1.cloudfront.net/',
        'AWS_LAMBDA_SERVICE_URL'             => 'https://dev-lambda.genmaverick.com/',
        'AWS_LAMBDA_API_KEY'                 => '0mbh8CXZZyWwYYGXbiDvuXka5HnAELNN',
        'AWS_LAMBDA_NOTIFICATION_URL'        => 'https://dev-lambda.genmaverick.com/notification/notification-dev-attemptToSend',
        'AWS_LAMBDA_DEEP_LINK_PROTOCOL'      => 'devmaverick',
        'AWS_SNS_TOPIC_MODERATION'           => 'arn:aws:sns:us-east-1:415196061258:dev_moderation',
        'AWS_SNS_TOPIC_CHANGE_CONTENT'       => 'arn:aws:sns:us-east-1:415196061258:dev_change_content',
        'AWS_SNS_TOPIC_EVENTS'               => 'arn:aws:sns:us-east-1:415196061258:bemaverick-events-topic-dev',

        // branch
        'MAVERICK_BRANCH_KEY'                => 'key_test_lizP6vq88cyTfTeD7RUnHmeaDseBmwts',

        // segment
        'MAVERICK_SEGMENT_KEY'                => '6x8BdaJK8Odj5SJR2wPhtayegTnqHctK',

        // leanplum
        'MAVERICK_LEANPLUM_APP_ID'                => 'app_0SPllvo97hhhTnIDUhOdGD5LSwOZQ519gBpej6zfYfs',
        'MAVERICK_LEANPLUM_CLIENT_KEY'                => 'dev_rXKEJHEZUA4vUVXkbntCphQ4I7pZikvinGl57IEYNc4',

        // CleanSpeak configs
        'MODERATION_ENABLED'                    => true,
        'CLEANSPEAK_API_KEY'                    => '6f793d3c-f656-46d3-a0be-a42779732b95',
        'CLEANSPEAK_USERNAME_APPLICATION_ID'    => 'c45cf0c6-194b-461d-83dd-06da83b7543a',
        'CLEANSPEAK_USERDATA_APPLICATION_ID'    => '3d92d8fa-0ebe-4008-abd9-df8f772f533e',
        'CLEANSPEAK_RESPONSE_APPLICATION_ID'    => '13d15aac-8dcd-4e03-9047-a0b02d21983d',
        'CLEANSPEAK_API_URL'                    => 'https://genmaverick-dev-cleanspeak-api.inversoft.io/',

        // twilio configs
        'TWILIO_ACCOUNT_SID'      => 'AC801dd47d6c01fd78cda331f705812405',
        'TWILIO_API_KEY'          => 'SKada2aec5632f5580b5eac516fde6c007',
        'TWILIO_API_SECRET'       => 'GK7snQ4FJTY4sDVEk8FaGAKCYPs91kZp',
        'TWILIO_SERVICE_SID'      => 'IS7bef147fba414e2e9248e336bb576d01',
        'TWILIO_APPNAME'          => 'dev_maverick',
        'TWILIO_ACCESSTOKEN'      => '60eb011a8dff7bd853550e68009ebbdd',
        'TWILIO_SMS_PHONE_NUMBER' => '+13233109572',

        // veratad configs
        'VERATAD_USERNAME'   => 'ws@bemaverick.com',
        'VERATAD_PASSWORD'   => 'Hfy763#dhe345',
        'VERATAD_SERVICE'    => 'IDMatchCOPPA5.0',
        'VERATAD_URL'        => 'https://production.idresponse.com/process/5/gateway',

        // sparkpost config
        'SPARKPOST_API_KEY'                  => 'fc65a7aa62f073c51a3e8be3b8a89e5ca5d3184b',

        // wordpress configs
        'WORDPRESS_API_URL'                  => 'http://cms.genmaverick.com/wp-json/wp/v2',
        'WORDPRESS_SITE_URL'                 => 'http://bemav-appli-1uxy9d14nn52c-663342170.us-east-1.elb.amazonaws.com/',

        // appstore config
        'SYSTEM_APP_STORE_APPLE_URL'         => 'https://appstore.com/bemaverickco/maverickdoyourthing',

        // twitter config
        'TWITTER_HANDLE'                     => 'genmaverick',
        'TWITTER_API_CONSUMER_KEY'           => 'pHoTsoWFDpm0YHRluD14gHAqf',
        'TWITTER_API_CONSUMER_SECRET'        => 'OX32nj9PXXQDUWBxlpwzKeDZjOqNyfncTCWQbYX8YOiuriaN5i',

        // facebook config
        'FACEBOOK_APP_ID'                    => '2098769993734812',
        'FACEBOOK_APP_SECRET'                => '412b262fae724794050d7c912632ce0e',

        // react app configs
        'REACT_APP_URL'                  => '',

        // zendesk config
        'ZENDESK_SUBDOMAIN'              => 'bemaverick',
        'ZENDESK_USERNAME'               => 'zendesk@bemaverick.com',
        'ZENDESK_TOKEN'                  => 'aBI4mWyLvoZr24ZHEvAN1NAHQhVXWGLADV66i1Y5',

    ),

    // START WEBSITE SETTINGS
    'website' => array(
        'SYSTEM_ROOT_DIR'                  => BEMAVERICK_WEBSITE_ROOT_DIR,
        'SYSTEM_HTTP_HOST'                 => "$USER-website-bemaverick.dev.slytrunk.com",
        'SYSTEM_SITE_SOURCE'               => 'website',
        'SYSTEM_PACKAGE_BUILD_VERSION_FILE'=> BEMAVERICK_WEBSITE_ROOT_DIR . '/package_build_version.txt',
        'SYSTEM_CDN_HOSTS'                 => array( "$USER-website-bemaverick.dev.slytrunk.com" ),


        'SYSTEM_CSS_DIRS' => array(
            BEMAVERICK_WEBSITE_ROOT_DIR . '/css/compiled',
            BEMAVERICK_WEBSITE_ROOT_DIR . '/css',
            BEMAVERICK_COMMON_ROOT_DIR . '/css/compiled',
            BEMAVERICK_COMMON_ROOT_DIR . '/css',
            SLY_ROOT_DIR . '/css',
            TWITTER_ROOT_DIR . '/bootstrap/3.0.2/css',
        ),
        'SYSTEM_IMAGE_DIRS' => array(
            BEMAVERICK_WEBSITE_ROOT_DIR . '/img',
            BEMAVERICK_COMMON_ROOT_DIR . '/img',
            SLY_ROOT_DIR . '/img',
            TWITTER_ROOT_DIR . '/bootstrap/3.0.2/img',
        ),
        'SYSTEM_JS_DIRS' => array(
            BEMAVERICK_WEBSITE_ROOT_DIR . '/js',
            BEMAVERICK_COMMON_ROOT_DIR . '/js',
            SLY_ROOT_DIR . '/js',
        ),
        'SYSTEM_MODULE_DIRS' => array(
            SLY_ROOT_DIR . '/modules',
            BEMAVERICK_COMMON_ROOT_DIR . '/modules',
            BEMAVERICK_WEBSITE_ROOT_DIR . '/modules',
        ),
        'SYSTEM_PAGE_DIRS' => array(
            BEMAVERICK_WEBSITE_ROOT_DIR . '/pages',
            BEMAVERICK_COMMON_ROOT_DIR . '/pages',
            SLY_ROOT_DIR . '/pages',
        ),
        'SYSTEM_FONT_DIRS' => array(
            BEMAVERICK_WEBSITE_ROOT_DIR . '/fonts',
            BEMAVERICK_COMMON_ROOT_DIR . '/fonts',
            SLY_ROOT_DIR . '/fonts',
            //TWITTER_ROOT_DIR . '/bootstrap/3.0.2/fonts',
        ),
        'SYSTEM_HELPERS' => array(
            array(
                'path'        => SLY_ROOT_DIR . '/lib/Sly/View/Helper',
                'classPrefix' => 'Sly_View_Helper',
            ),
            array(
                'path'        => BEMAVERICK_COMMON_ROOT_DIR . '/helpers',
                'classPrefix' => 'BeMaverick_View_Helper',
            ),
            array(
                'path'        => BEMAVERICK_WEBSITE_ROOT_DIR . '/helpers',
                'classPrefix' => 'BeMaverick_Website_View_Helper',
            ),
        ),

        'SYSTEM_USE_CRITICAL_CSS'           => true,
        'SYSTEM_MINIFY_CSS_JS_ENABLED'      => true,
        'SYSTEM_IS_SITE_RESPONSIVE'         => true,
        'SYSTEM_INCLUDE_NOSCRIPT_IMAGES'    => true,
    ),
    // END ADMIN SETTINGS

    // START API SETTINGS
    'api' => array(
        'SYSTEM_ROOT_DIR'                  => BEMAVERICK_API_ROOT_DIR,
        'SYSTEM_HTTP_HOST'                 => "$USER-api-bemaverick.dev.slytrunk.com",
        'SYSTEM_SITE_SOURCE'               => 'api',
        'SYSTEM_PACKAGE_BUILD_VERSION_FILE'=> BEMAVERICK_API_ROOT_DIR . '/package_build_version.txt',
        'SYSTEM_API_VERSION'               => 'v1',
        'SYSTEM_SERVICE_DOCS_XML_DIR'      => BEMAVERICK_API_ROOT_DIR . '/docs/services',

        'SYSTEM_CSS_DIRS' => array(
            BEMAVERICK_API_ROOT_DIR . '/css/compiled',
            BEMAVERICK_API_ROOT_DIR . '/css',
            SLY_ROOT_DIR . '/css',
            TWITTER_ROOT_DIR . '/bootstrap/3.0.2/css',
        ),
        'SYSTEM_IMAGE_DIRS' => array(
            BEMAVERICK_API_ROOT_DIR . '/img',
            SLY_ROOT_DIR . '/img',
            TWITTER_ROOT_DIR . '/bootstrap/3.0.2/img',
        ),
        'SYSTEM_JS_DIRS' => array(
            BEMAVERICK_API_ROOT_DIR . '/js',
            SLY_ROOT_DIR . '/js',
        ),
        'SYSTEM_MODULE_DIRS' => array(
            SLY_ROOT_DIR . '/modules',
            BEMAVERICK_API_ROOT_DIR . '/modules',
        ),
        'SYSTEM_PAGE_DIRS' => array(
            BEMAVERICK_API_ROOT_DIR . '/pages',
            SLY_ROOT_DIR . '/pages',
        ),
        'SYSTEM_FONT_DIRS' => array(
            BEMAVERICK_API_ROOT_DIR . '/fonts',
            SLY_ROOT_DIR . '/fonts',
            //TWITTER_ROOT_DIR . '/bootstrap/3.0.2/fonts',
        ),
        'SYSTEM_HELPERS' => array(
            array(
                'path'        => SLY_ROOT_DIR . '/lib/Sly/View/Helper',
                'classPrefix' => 'Sly_View_Helper',
            ),
            array(
                'path'        => BEMAVERICK_API_ROOT_DIR . '/helpers',
                'classPrefix' => 'BeMaverick_Api_View_Helper',
            ),
        ),
    ),
    // END API SETTINGS

    // START ADMIN SETTINGS
    'admin' => array(
        'SYSTEM_ROOT_DIR'                  => BEMAVERICK_ADMIN_ROOT_DIR,
        'SYSTEM_HTTP_HOST'                 => "$USER-admin-bemaverick.dev.slytrunk.com",
        'SYSTEM_SITE_SOURCE'               => 'admin',
        'SYSTEM_PACKAGE_BUILD_VERSION_FILE'=> BEMAVERICK_ADMIN_ROOT_DIR . '/package_build_version.txt',

        'SYSTEM_ADMIN_ADD_MAX_RESPONSES_AT_ONE_TIME' => 10,
        'SYSTEM_ADMIN_MAX_PROFILE_COVER_PRESET_IMAGES' => 15,

        'SYSTEM_CSS_DIRS' => array(
            BEMAVERICK_ADMIN_ROOT_DIR . '/css/compiled',
            BEMAVERICK_ADMIN_ROOT_DIR . '/css',
            BEMAVERICK_COMMON_ROOT_DIR . '/css',
            SLY_ROOT_DIR . '/css',
            TWITTER_ROOT_DIR . '/bootstrap/2.3.2/css',
        ),
        'SYSTEM_IMAGE_DIRS' => array(
            BEMAVERICK_ADMIN_ROOT_DIR . '/img',
            SLY_ROOT_DIR . '/img',
            TWITTER_ROOT_DIR . '/bootstrap/2.3.2/img',
        ),
        'SYSTEM_JS_DIRS' => array(
            BEMAVERICK_ADMIN_ROOT_DIR . '/js',
            SLY_ROOT_DIR . '/js',
        ),
        'SYSTEM_MODULE_DIRS' => array(
            SLY_ROOT_DIR . '/modules',
            BEMAVERICK_ADMIN_ROOT_DIR . '/modules',
        ),
        'SYSTEM_PAGE_DIRS' => array(
            BEMAVERICK_ADMIN_ROOT_DIR . '/pages',
            SLY_ROOT_DIR . '/pages',
        ),
        'SYSTEM_FONT_DIRS' => array(
            BEMAVERICK_ADMIN_ROOT_DIR . '/fonts',
            SLY_ROOT_DIR . '/fonts',
            //TWITTER_ROOT_DIR . '/bootstrap/3.0.2/fonts',
        ),
        'SYSTEM_HELPERS' => array(
            array(
                'path'        => SLY_ROOT_DIR . '/lib/Sly/View/Helper',
                'classPrefix' => 'Sly_View_Helper',
            ),
            array(
                'path'        => BEMAVERICK_COMMON_ROOT_DIR . '/helpers',
                'classPrefix' => 'BeMaverick_View_Helper',
            ),
            array(
                'path'        => BEMAVERICK_ADMIN_ROOT_DIR . '/helpers',
                'classPrefix' => 'BeMaverick_Admin_View_Helper',
            ),
        ),
    ),
    // END ADMIN SETTINGS

);

return $settings;

?>
