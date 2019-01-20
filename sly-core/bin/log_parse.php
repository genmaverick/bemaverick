<?php

$handle = popen("tail -f /www/sites/fantasy.nfl.com/logs/access/access_log | cut -d ' ' -f 7,9,10", "r");

$pages = array();

$i = 1;

while (true) {

      $line = fgets($handle);
      $parts = explode(' ', $line);

      $url = $parts[0];
      $rc = $parts[1];
      $time = $parts[2];

      $urlNoArgs = explode('?', $url);

      // Replace numbers with 'n'
      $urlParts = explode('/', $urlNoArgs[0]);

      foreach ($urlParts as &$part) {
          if (is_numeric($part)) {
	      $part = 'n';	     			 
	  }
      }

      $normalizedUrl = implode('/', $urlParts);

      @$pages[$normalizedUrl]['views']++;
      @$pages[$normalizedUrl]['totalTime'] += $time;
      @$pages[$normalizedUrl]['rcs'][$rc]++;

      $i++;

      if (($i % 250) == 0) {

      	  uasort($pages, 'sortByViews');

	  $pages = array_slice($pages, 0, 10);
      
          print "============================================================================\n";
	  print strftime("%c") . "\n";
	  foreach ($pages as $url => $data) {
	      print "{$data['views']} - $url\n";
	      printf("    Average Time: %.2f\n", $data['totalTime']/$data['views']);
	      if (count($data['rcs']) > 1) {
	          print "    Non-200 status codes\n";
	      }
	  }

          $i = 1;
	  $pages = array();
      }
}

function sortByViews($a, $b) {
    if ($a['views'] > $b['views']) {
        return(-1);
    } else if ($a['views'] < $b['views']) {
        return(1);
    } else {
        return(0);
    }
}

?>