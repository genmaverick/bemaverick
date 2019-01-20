<?php

require_once( SLY_ROOT_DIR . '/lib/Sly/Service/Tumblr/Blog.php' );

class Sly_View_Helper_FormatBlog {

    const BLOG_PAGE_GET_PARAM = 'page';
    const BLOG_POST_ID_GET_PARAM = 'postId';

    public function formatBlog () {
        return $this;
    }

    /*
    public function init (Sly_Service_Tumblr_Blog $blog, $currentPage = 1, $postId = null) {
        $this->blog = $blog;
        $this->currentPage = $currentPage;
        if ($postId && is_numeric($postId)) {
            $this->isSinglePost = true;
            $this->postId = strval($postId);
        }
    }
    */

    public function renderPostList ($blog, $currentPost) {
        $posts = $blog->getPosts();

        $postsMarkup = '';
        $postRenderer = $this->view->formatBlogPost();
        foreach ($posts as $post) {
            $isCurrentPost = ($currentPost && $post->getId() == $currentPost->getId());
            $postsMarkup[$post->getId()] = array('title' => $this->view->htmlElement()->tag('a', $post->getTitle(), array('href' => '/blog?postId=' . $post->getId(),
                                                                                                                          'data-sly-header-name' => 'blog')));
        }
        if (!$currentPost) {
            $postsMarkup = $this->view->linkList($postsMarkup);
        }
        else {
            $postsMarkup = $this->view->linkList($postsMarkup, array('selected' => $currentPost->getId()));
        }

        return $postsMarkup;
    }

    public function renderPosts ($posts) {
        $postsMarkup = '';
        $postRenderer = $this->view->formatBlogPost();
        foreach ($posts as $post) {
            $postsMarkup[] = array('title' => $postRenderer->renderPost($post));
        }

        $postsMarkup = $this->view->linkList($postsMarkup);

        return $postsMarkup;
    }

    public function getPageTitle ($blog, $post = null) {
        $page_title = $blog->getBlogName() . " Blog";
        if ($post) {
            $page_title = $post->getTitle();
        }
        return $page_title;
    }

    protected function getPageUrl ($pageNumber) {
        return '/blog?' . self::BLOG_PAGE_GET_PARAM . '=' . $pageNumber;
    }


    public $view;

    public function setView( Zend_View_Interface $view )
    {
        $this->view = $view;
    }

}

?>
