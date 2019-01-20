<?php

class Sly_View_Helper_FormatBlogPost {

    public function formatBlogPost () {
        return $this;
    }

    /*
    public function init ($post, $isSinglePost = true) {
        $this->post = $post;
        $this->isSinglePost = $isSinglePost;
    }
    */

    public function renderPost ($post) {
        $titleMarkup = $this->renderPostRibbonTitle($post);
        $postMarkup  = $this->renderPostBody($post);
        $byLine      = $this->renderPostByline($post);
        $tags        = $this->renderPostTags($post);
        //$comments = $this->renderComments();

        $tHtml = $this->view->htmlElement();
        $postMarkup = 
            $tHtml->tag('div', 
                        $titleMarkup . $byLine . $tags . $postMarkup,
                        array('id'    => 'blogPost-' . $post->getId(),
                              'class' => 'blogPost'));
        
        return $postMarkup;
    }

    public function renderPostTitle ($post, $h = 'h2') {
        $html = $this->view->htmlElement();
        return 
            $html->tag('div', 
                       $html->tag($h, 
                                  $post->getTitle()),
                       array('class' => 'title'));
    }

    public function renderPostRibbonTitle ($post, $h = 'h2') {
        $html = $this->view->htmlElement();
        return 
            $html->tag('div', 
                       $html->tag($h, 
                                  $html->tag('b', '') .
                                  $html->tag('span', $post->getTitle()),
                                  array('class' => 'ribbon')),
                       array('class' => 'title'));
    }

    public function renderPostByline ($post) {
        $html = $this->view->htmlElement();

        return 
            $html->tag('div', 
                       $html->tag('div', 
                                  $post->getFormattedDate(),
                                  array('class' => 'date')),
                       /*
                       $html->tag('div', 
                                  'Posted by Ben',
                                  array('class' => 'author')),
                       */
                       array('class' => 'byline'));
    }

    public function renderPostBody ($post) {
        return 
            $this->view->htmlElement()->tag('div', 
                                            $post->getBody(),
                                            array('class' => 'body'));
    }

    public function renderPostTags ($post) {
        return 
            $this->view->htmlElement()->tag('div', 
                                            $this->view->htmlElement()->tag('strong', 'Tags') . ': ' . 
                                            implode('|', $post->getTags()),
                                            array('class' => 'tags'));
    }

    /*
    public function renderComments () {
        $url = $this->getPostUrl($post);

        if ($this->isSinglePost) {
            $comments = <<<HTML
                <div id="fb-root"></div><script src="http://connect.facebook.net/en_US/all.js#xfbml=1"></script><fb:comments href="{$url}" num_posts="5" width="914"></fb:comments>
                HTML;
        }
        else {
            $url = urlencode($url);
            $comments = <<<HTML
                <iframe src="http://www.facebook.com/plugins/comments.php?href={$url}&permalink=1" scrolling="no" frameborder="0" style="border:none; overflow:hidden; width:130px; height:16px;" allowTransparency="true"></iframe>
                HTML;
        }
        return $comments;
    }
    */

    protected function getPostUrl ($post) {
        $url = "slytrunk.com/blog?post_id=" . $post->getId();
        return $url;
    }

    public $view;

    public function setView( Zend_View_Interface $view )
    {
        $this->view = $view;
    }

}

?>
