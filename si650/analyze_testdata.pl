#!/usr/bin/perl

use strict;
use Data::Dumper;
use File::Slurp;

{
    my @positive = read_file('positive.txt');
    my @negative = read_file('negative.txt');

    my $positive_words;
    foreach my $line (@positive)  {
        chomp($line);
    	my ($score, $word) = split(/\ /, $line);
    	$positive_words->{$word} = $score;
    }
    my $negative_words;
    foreach my $line (@negative)  {
        chomp($line);
        my ($score, $word) = split(/\ /, $line);
        $negative_words->{$word} = $score;
    }

    # Input a line from stdin
    while (my $line = <STDIN>) {

	    chomp($line);
        $line =~ s/can\'t/\cannot/g;
        $line =~ s/don\'t/\do not/g;
        $line =~ s/won\'t/\will not/g;
        $line =~ s/haven\'t/\have not/g;

    	my @words = split (/\ /, $line);
    
    	my $pos_score = 0;
    	my $neg_score = 0;

        foreach my $word (@words) {
            next if substr($word, 0, 1) eq '@'; # remove tags but not hashtags

    	    chomp($word);
    	    my $modifier = uc($word) eq $word ? 4 : 1; # all caps?
    	    $modifier = 2 if $modifier == 1 and lcfirst($word) ne $word;
    
    	    $pos_score += 100 if $word eq ":)";
    	    $pos_score += 100 if $word eq ":-)";
    	    $pos_score += 150 if $word eq "=)";
    	    $pos_score += 200 if $word eq ":-D";
    	    $pos_score += 200 if $word eq ":D";
    	    $pos_score += 250 if $word eq "=D";
    	    $neg_score += 100 if $word eq ":(";
    	    $neg_score += 100 if $word eq ":-(";
    	    $neg_score += 150 if $word eq "=(";
    
            $word =~ s/[^\w]//g;
    
    	    next unless $word;
    
    	    $word = lc($word);

            $word =~ s/sucks/suck/;
            $word =~ s/sucked/suck/;
            $word =~ s/loved/love/;
            $word =~ s/liked/like/;
            $word =~ s/loving/love/;
            $word =~ s/motherfucking/fuck/;
            $word =~ s/motherfucker/fuck/;
            $word =~ s/fucking/fuck/;
            $word =~ s/fucked/fuck/;
            $word =~ s/fucks/fuck/;

    	    $pos_score += $positive_words->{$word} * $modifier
    	        if grep(/$word/, keys %$positive_words);
    	    $neg_score += $negative_words->{$word} * $modifier
    	        if grep(/$word/, keys %$negative_words);
	    
	    }

    	my $tot_score = scalar($pos_score - $neg_score);
    	if ($ARGV[0] eq '-cli') {
    	    print "Pos: $pos_score Neg: $neg_score Tot: $tot_score - ";
    	    print $tot_score > 0 ? 'POSITIVE' : 'NEGATIVE';
    	    print "\n";
    	} else {
    	    print $tot_score > 0 ? "1\n" : "0\n";
    	}
    }
}
