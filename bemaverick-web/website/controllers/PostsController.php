<?php
//
//require_once( BEMAVERICK_COMMON_ROOT_DIR . '/controllers/Base.php' );
//
//class PostsController extends BeMaverick_Controller_Base
//{
//
//    /**
//     * The post page
//     *
//     * @return void
//     */
//    public function postAction()
//    {
//        // get the view vars
//        $errors = $this->view->errors;
//        $site = $this->view->site;         /* @var BeMaverick_Site $site */
//
//        // set the input params
//        $requiredParams = array(
//            'postId',
//        );
//
//        $input = $this->processInput( $requiredParams, null, $errors );
//
//        // check if there were any errors
//        if ( $errors->hasErrors() ) {
//            return $this->renderPage( 'errors' );
//        }
//
//        // get the post
//        $post = $site->getPost( $input->postId );
//
//        // set the view vars
//        $this->view->post = $post;
//
//        return $this->renderPage( 'post' );
//    }
//
//
//}
