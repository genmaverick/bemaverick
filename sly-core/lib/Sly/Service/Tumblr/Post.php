<?php

class Sly_Service_Post {

    protected $post;

    protected $id;
    protected $date;
    protected $title;
    protected $body;

    public function __construct ($post) {
        $this->id    = $post['id'];
        $this->date  = $post['timestamp'];
        $this->title = $post['title'];
        $this->body  = $post['body'];

        $this->post  = $post;
    }

    public function getId () {
        return $this->id;
    }

    public function getDate () {
        return $this->date;
    }

    public function getFormattedDate () {
        $month_day = date("l F j", $this->date);
        $year = (date("Y", $this->date) !== date("Y")) ? date(", Y", $this->date) : '';
        $time = date("ga", $this->date);

        $date = $month_day . $year . ', ' . $time;
        return $date;
    }

    public function getTitle () {
        return $this->title;
    }

    public function getBody () {
        return $this->body;
    }

    public function getTags () {
        return $this->post['tags'];
    }



  public function titleToHtml ($h = 4) {
    $title = $this->getTitle();
    $date  = $this->getFormattedDate();
    $url   = '?post_id=' . $this->getId();
    return <<<HTML
<h{$h}>{$title}</h{$h}><a href="{$url}">{$date}</a>
HTML;
  }

  public function bodyToHtml () {
    $body  = $this->getBody();
    return <<<HTML
{$body}
HTML;
  }

}

?>
