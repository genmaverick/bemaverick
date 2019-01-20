<?php

require_once( BEMAVERICK_COMMON_ROOT_DIR . '/controllers/Base.php' );

class IndexController extends BeMaverick_Controller_Base
{

    /**
     * The home page
     *
     * @return void
     */
    public function indexAction()
    {
        // get the view vars
        $site = $this->view->site;
        $errors = $this->view->errors;
        $loginUser = $this->view->loginUser;

        if ( $loginUser ) {
            $status = $loginUser->getStatus();
            // if user is revoked or deleted, log them out
            if ( $status == 'revoked' || $status == 'deleted' ) {
                // delete the cookie
                BeMaverick_Cookie::deleteUserCookie();

                if ($status == 'deleted') {
                    $errors->setError('', 'USER_ACCOUNT_DELETED');
                } elseif ($loginUser->getRevokedReason() == 'parental') {
                    $errors->setError('', 'USER_ACCOUNT_REVOKED_PARENT');
                } else {
                    $errors->setError('', 'USER_ACCOUNT_REVOKED_ADMIN');
                }

                $redirectUrl = $site->getUrl( 'revoked' );

                if ( $this->view->ajax ) {
                    $this->view->redirectUrl = $redirectUrl;
                    return $this->renderPage( 'redirect' );
                }

                return $this->renderPage( 'revoked' );
            }

            $page = 'challenges'; // default logged in users to /challenges
            if ( $loginUser->getUserType() == BeMaverick_User::USER_TYPE_KID ) {
                // $page = 'maverickHome';
                $page = 'challenges';
            } else if ( $loginUser->getUserType() == BeMaverick_User::USER_TYPE_PARENT ) {
                $page = 'parentHome';
            }

            $redirectUrl = $site->getUrl( $page );

            if ( $this->view->ajax ) {
                $this->view->redirectUrl = $redirectUrl;
                return $this->renderPage( 'redirect' );
            }
            $redirectUrl = $site->getUrl( $page );
            return $this->_redirect( $redirectUrl );
        }

        // if not in production and not logged in, direct to react app homepage
        // if coming from the php site, redirect
        if ( $this->view->ajax ) {
            $this->view->redirectUrl = '/homepage';
            return $this->renderPage( 'redirect' );
        }

        // get url
        $systemConfig = $site->getSystemConfig();
        $wordpressUrl = $systemConfig->getSetting( 'WORDPRESS_SITE_URL' );
        $url = $wordpressUrl;

        // cURL & Render
        $this->renderCurlUrl($url);
    }

    /**
     * The maverick (kid) home page
     *
     * @return void
     */
    public function maverickHomeAction()
    {
        $errors = $this->view->errors;
        $site = $this->view->site;
        $loginUser = $this->view->loginUser;

        $input = $this->processInput( null, null, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        if ( ! $loginUser ) {
            // $redirectUrl = $site->getUrl( 'home' );
            $redirectUrl = '/homepage'; // react dedicated homepage route
            return $this->_redirect( $redirectUrl );
        }

        $successPage = 'user';
        $this->view->user = $loginUser;

        if ( $this->view->ajax && $this->view->ajax != 'dynamicModule' ) {
            $successPage = $this->view->ajax.'Ajax';
        }

        return $this->renderPage( $successPage );
    }

    /**
     * The temporary kid home page if kid tries to log in from grown up login
     *
     * @return void
     */
    public function tempHomeAction()
    {
        $errors = $this->view->errors;

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        $successPage = 'tempHome';
        if ( $this->view->ajax && $this->view->ajax != 'dynamicModule' ) {
            $successPage = $this->view->ajax.'Ajax';
        }
        return $this->renderPage( $successPage );
    }

    /**
     * The splash page -- only used to generate content for wordpress insert
     *
     * @return void
     */
    public function splashAction()
    {
        return $this->renderPage( 'home' );
    }

    /**
     * The mobile app terms of service and privacy policy page
     *
     * @return void
     */
    public function termsOfServiceAndPrivacyPolicyAction()
    {
        return $this->renderPage( 'termsOfServiceAndPrivacyPolicy' );
    }

    /**
 * The brooklyn and bailey giveaway page
 *
 * @return void
 */
    public function bbGiveawayAction()
    {
        return $this->renderPage( 'bbGiveaway' );
    }

    /**
     * The laurie hernandez giveaway page
     *
     * @return void
     */
    public function laurieGiveawayAction()
    {
        return $this->renderPage( 'laurieGiveaway' );
    }

    /**
     * The the c and halle giveaway page
     *
     * @return void
     */
    public function cxhGiveawayAction()
    {
        return $this->renderPage( 'cxhGiveaway' );
    }

    /**
     * The home page
     *
     * @return void
     */
    public function familyHomeAction()
    {
        $errors = $this->view->errors;
        $site = $this->view->site;
        $validator = $this->view->validator;
        $loginUser = $this->view->loginUser;

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        $input = $this->processInput( null, null, $errors );

        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        if ( ! $loginUser ) {
            $redirectUrl = $site->getUrl( 'home' );
            return $this->_redirect( $redirectUrl );
        }


        $successPage = 'user';
        if ( $this->view->ajax && $this->view->ajax != 'dynamicModule' ) {
            $successPage = $this->view->ajax.'Ajax';
        }

        $kids = $loginUser->getKids();

        if ( $kids ) {
            $this->view->user = $kids[0];
        } else {
            // todo : where to go if parent has no kids
        }

        return $this->renderPage( $successPage );

    }

    /**
     *
     * Confirmation of changes saved
     *
     * @return void
     */
    public function confirmationAction()
    {
        return $this->renderPage( 'confirmation' );
    }

    /**
     * The challenges page
     *
     * @return void
     */
    public function challengesAction()
    {
        // get the view vars
        $errors = $this->view->errors;
        $site = $this->view->site;         /* @var BeMaverick_Site $site */
        $loginUser = $this->view->loginUser;

        // if not logged in, send to public challenge page (wordpress)
        // if logged in, send to php challenge page
        if ( $loginUser ) {
            // set the input params
            $optionalParams = array(
                'count',
                'offset',
                'startCount'
            );

            $input = $this->processInput( null, $optionalParams, $errors );

            // check if there were any errors
            if ( $errors->hasErrors() ) {
                return $this->renderPage( 'errors' );
            }

            $successPage = 'challenges';
            if ( $this->view->ajax && $this->view->ajax != 'dynamicModule' ) {
                $successPage = $this->view->ajax.'Ajax';
            }

            return $this->renderPage( $successPage );
        } else {
            // if coming from the php site, redirect
            if ( $this->view->ajax ) {
                $this->view->redirectUrl = 'challenges';
                return $this->renderPage( 'redirect' );
            }

            // get url
            $systemConfig = $site->getSystemConfig();
            $wordpressUrl = $systemConfig->getSetting( 'WORDPRESS_SITE_URL' );
            $url = $wordpressUrl.'challenges/';

            // cURL & Render
            $this->renderCurlUrl($url);
        }
    }

    /**
     * The React reverse proxy
     *
     * @return void
     */
    public function reactAppAction()
    {
        $site = $this->view->site;
        $path = $_SERVER['REQUEST_URI'];

        // if coming from the php site, redirect
        if ( $this->view->ajax ) {
            $this->view->redirectUrl = $path;
            return $this->renderPage( 'redirect' );
        }

        // get url
        $path = trim($path, '/');
        $systemConfig = $site->getSystemConfig();
        $reactAppUrl = trim($systemConfig->getSetting( 'REACT_APP_URL' ), '/');
        $url = $reactAppUrl . '/' . $path;

        // cURL & Render
        $this->renderCurlUrl($url);
    }

    /**
     * The wordpress reverse proxy
     *
     * @return void
     */
    public function wordpressAction()
    {
        $site = $this->view->site;
        $path = $_SERVER['REQUEST_URI'];

        // if coming from the php site, redirect
        if ( $this->view->ajax ) {
            $this->view->redirectUrl = $path;
            return $this->renderPage( 'redirect' );
        }

        // get url
        $path = trim($path, '/');
        $systemConfig = $site->getSystemConfig();
        $reactAppUrl = trim($systemConfig->getSetting( 'WORDPRESS_SITE_URL' ), '/');
        $url = $reactAppUrl . '/' . $path . '/';

        // cURL & Render
        $this->renderCurlUrl($url);
    }

    private function renderCurlUrl($url) {
        // curl the remote url
        $curl = curl_init($url);
        curl_setopt($curl, CURLOPT_RETURNTRANSFER, TRUE);
        $output = curl_exec($curl);
        curl_close($curl);

        // disable zend rendering
        $this->_helper->viewRenderer->setNoRender(true);
        $this->view->layout()->disableLayout();

        if(trim($output)==='') {
            http_response_code(500);
            echo "Error: Could not load page";
        } else {
            // output the curl request
            echo $output;
        }
        exit();
    }

}

?>
