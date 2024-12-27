#!/usr/bin/perl -wT
#
# SI 650: Information Retrieval
# Mikko Tuomela <mstuomel@umich.edu>

use strict;
edit_distance('national',   'natural');
edit_distance('vedio_tape', 'videotape');

exit;

sub edit_distance {
    my ($first, $second) = @_;
    print "Edit distance between \"$first\" and \"$second\":\n";

    my $m = [];

    my $first_len  = length($first);
    my $second_len = length($second);

    $m->[$_][0] = $_ for (0 .. $first_len);
    $m->[0][$_] = $_ for (0 .. $second_len);

    for my $i (1 .. $first_len) {
		for my $j (1 .. $second_len) {
			
			my $corner = $m->[$i - 1][$j - 1]
				+ (get_char($first, $i) eq get_char($second, $j) ? 0 : 1);
			my $left   = $m->[$i - 1][$j] + 1;
			my $above  = $m->[$i][$j - 1] + 1;
			
			$m->[$i][$j] = min($corner, $left, $above);
		}
		
    }
	
    # Print array
    print "\n";
    for my $j (0 .. $second_len) {
		for my $i (0 .. $first_len) {
			printf("%2.1d ", $m->[$i][$j]);
		}
		print "\n";
    }
    print "\n";
}

sub min {
    my (@n) = @_;
    @n = sort { $b <= $a } @n;
    return $n[0];
}

sub get_char {
    my ($string, $n) = @_;
    my $char = substr($string, $n - 1, 1);
    return $char;
}
