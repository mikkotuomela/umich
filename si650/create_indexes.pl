#!/usr/bin/perl

use strict;
use constant FILE => 'training2.txt';
use File::Slurp;

$| = 1;

{

    # Stop words and other words that should not be included in the score
    my @remove = qw(harry potter impossible mission da vinci brokeback 
                    mountain code movie film 1 2 3 movies
                    the and a an to from which what that so as
                    g or me it la ti al us id be ve x am we no go do ca
                    ur et ate one ive have had j ill our her up end of can
                    are here there where my you for if tom but too its
                    kate felicia virgin desperately reading all ever ap some
                    day any man fic every very his her their was were just
                    how about say um umm ps tc eek iii ii series demons xmen
                    books goblet culture cruise watched);

    my $positive = { };
    my $negative = { };

    # Go through training data
    open (IN, FILE) or die "$!";
    while (my $line = <IN>) {

	chomp($line);

	# Divide the line into 1/0 and text
	my ($result, $text) = split (/\t/, $line);

	# Some easy fixes don't -> do not etc.
	$text =~ s/can\'t/\cannot/g;
	$text =~ s/don\'t/\do not/g;
	$text =~ s/won\'t/\will not/g;
	$text =~ s/haven\'t/\have not/g;

	# Split the text into words
	my @words = split (/\ /, $text);

	# Go through every word
	foreach my $word (@words) {

	    # If this is a tweet, ignore tags completely
	    next if substr($word, 0, 1) eq '@';

	    # Too lazy to implement real skimming but this helps, too
	    $word = lc($word);
	    $word =~ s/\'s//;
	    $word =~ s/[^\w]//g;
	    $word =~ s/wanna/want\ to/;
	    $word =~ s/sucks/suck/;
	    $word =~ s/sucked/suck/;
	    $word =~ s/sucking/suck/;
	    $word =~ s/loved/love/;
	    $word =~ s/liked/like/;
	    $word =~ s/loving/love/;
	    $word =~ s/motherfucking/fuck/;
	    $word =~ s/fucking/fuck/;
	    $word =~ s/fucked/fuck/;
	    $word =~ s/fucks/fuck/;

	    # Go to next word if there is nothing left of this word
	    next unless $word;

	    # Go to the next word if this word is in the remove list
	    next if grep(/$word/, @remove);

	    # Add this word into the results
	    if ($result) {
		$positive->{$word}++;
	    } else {
		$negative->{$word}++;
	    }
	}
    }
    close IN;

    # Corrections to the score, based on reading the file
    $positive->{right}    = 50;
    $positive->{really}   = 15;
    $positive->{sexy}     = 30;
    $negative->{ugly}     = 10;
    $negative->{right}    = 0;
    $negative->{really}   = 0;
    $negative->{crap}     = 200;
    $negative->{shit}     = 300;
    $negative->{american} = 30;
    $negative->{purdue}   = 30;

    # Sort by score
    print "Sorting positive...";
    my @positive_sorted = sort { 
	$positive->{$b} <=> $positive->{$a} } keys %$positive;
    print "Done\n";
    print "Sorting negative...";
    my @negative_sorted = sort { 
	$negative->{$b} <=> $negative->{$a} } keys %$negative;
    print "Done\n";

    # Write data into files
    print "Writing files...";
    open (POSITIVE, ">positive.txt") or die "$!";
    print POSITIVE $positive->{$_} . " $_\n" for @positive_sorted;
    close POSITIVE;
    open (NEGATIVE, ">negative.txt") or die "$!";
    print NEGATIVE $negative->{$_} . " $_\n" for @negative_sorted;
    close NEGATIVE;
    print "Done\n";

    print "Positive words: " . scalar(keys %$positive) . "\n";
    print "Negative words: " . scalar(keys %$negative) . "\n";
    print "Finished.\n";

}

