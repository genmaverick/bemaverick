#!/usr/bin/perl -w

use strict;
use Getopt::Std;
use IO::File;

getopts('i:pt');

$| = 1;

my $interval = defined $::opt_i ? $::opt_i : 5;
my $passthru = defined $::opt_p ? $::opt_p : 0;
my $fh       = new IO::File;
my %total    = ();

if (scalar @ARGV) {
  $fh->open('<' . $ARGV[0]) or die $!;
  $fh->seek(0, SEEK_END) or die $!;
}
else {
  $fh->open('<&STDIN') or die $!;
}

$SIG{ALRM} = sub { die };

while (1) {
  my $start         = scalar time;
  my $current_time  = $start;
  my $earliest      = $start;
  my $elapsed       = 0;
  my $rolling_total = 0;

  alarm(1);
  eval {
    while (defined (my $line = $fh->getline())) {
      print $line if $passthru;
      $current_time = scalar time;
      $total{$current_time}++;
      last if $current_time != $start;
    }
    alarm(0);
  };

  if ($fh->eof()) {
    $fh->clearerr();
    $fh->seek(0, SEEK_END);
    sleep 1 if $current_time == $start;
  }

  $total{$start} = 0 unless exists $total{$start};

  for my $t (keys %total) {
    next if $t > $start;
    if ($t <= $start - $interval) {
      delete $total{$t};
    }
    else {
      $earliest       = $t if $t < $earliest;
      $rolling_total += $total{$t};
    }
  }

  $elapsed = $start - $earliest + 1;

  if (defined $::opt_t and $::opt_t) {
    printf STDERR "%s: %.2f /s\n", scalar localtime, $rolling_total/$elapsed;
  }
  else {
    printf STDERR "%.2f /s\n", $rolling_total/$elapsed;
  }
}

$fh->close();

