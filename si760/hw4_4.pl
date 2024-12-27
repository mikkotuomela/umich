#!/usr/bin/perl

use strict;
use constant CORPUS => 'brown/complete.txt';
use File::Slurp;
use Data::Dumper;

{

	my $start_p = { };
	my $state_count = { };
#	my $observation_count = { };
	my $emission_p = { };
	my $emission_count = { };
	my $transition_p = { };
	my $transition_count = { };
	my $n = 0;

	# Read the concatenated Brown files
    my @lines = read_file(CORPUS);

	# Loop through all lines
    foreach my $line (@lines) {
		my $line   = lc(trim($line));    # remove whitespace and caps		
		next unless $line;               # next if no content
		my @tokens = split(/\ /, $line); # split line into tokens

		# To count start probabilities
		$start_p->{$tokens[0]}++;
		$n++;
		
		# Go through all tokens 
		my $i = 0;
		foreach my $token (@tokens) {
			my ($word, $tag) = split(/\//, $token); # Separate word and POS tag
			$state_count->{$tag}++;
#			$observation_count->{$word}++;

			if ($i < scalar @tokens) {
				my $next = $tokens[$i + 1];
				my ($next_word, $next_tag) =  split(/\//, $next);
				$transition_p->{$tag}{$next_tag}++;
				$transition_count->{$tag}++;
				$emission_p->{$word}{$next_tag}++;
				$emission_count->{$word}++;
			}

			$i++;
		} 
		last if $n == 5;
    }


	# List of all observations
	my @observations = qw(hello every body , how are you doing ?);

	# List of all states
	my @states = keys %$state_count;

	# Get start probability data
	foreach my $tag (keys %$start_p) {
		$start_p->{$tag} /= $n;
	}

	# Get transition probability matrix
	foreach my $tag (keys %$transition_p) {
		my @transitions = keys %{$transition_p->{$tag}};
		foreach my $next_tag (@transitions) {
			$transition_p->{$tag}{$next_tag} /= $transition_count->{$tag};
		}
	}

	# Get emission probability matrix
	foreach my $word (keys %$emission_p) {
		my @emissions = keys %{$emission_p->{$word}};
		foreach my $next_tag (@emissions) {
			$emission_p->{$word}{$next_tag} /= $emission_count->{$word}; 
		}
	}

	# Now we have all training data...

	

	print Dumper $transition_p;
	print Dumper $emission_p;
	print Dumper $start_p;

	viterbi(\@observations, \@states, $start_p, $transition_p, $emission_p);
}

sub trim {
	my $string = shift;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
}

# The actual algorithm
sub viterbi {
	my ($observations, $states, $start_p, $transition_p, $emission_p) = @_;
	my $viterbi = [ ];
	my $path    = { };
	
	foreach my $state (@$states) {
		$viterbi->[0]{$state} = 
			$start_p->{$state} * $emission_p->{$state}{$observations->[0]};
		$path->{$state} = [$state];
	}
 
	foreach my $o (1 .. (scalar @$observations - 1)) {
		my $new_path = { };
		
		foreach my $state (@$states) {
			my $max_prob = 0;
			my $max_state;

			# Check which path has the highest probability
			foreach my $check_state (@$states) {
				my $prob = $viterbi->[$o - 1]{$check_state} 
				    * $transition_p->{$check_state}{$state} 
				    * $emission_p->{$state}{$observations->[$o]};
				if ($prob > $max_prob) {
					$max_prob = $prob;
					$max_state = $check_state;
				}
			}
			$viterbi->[$o]{$state} = $max_prob;
			$new_path->{$state} = [$path->{$max_state}, $state];
			warn Dumper $new_path;
		}
		$path = $new_path;
	} # End $o

	# Find the best
	my $max_score = 0;
	my $max_state;

	foreach my $state (@$states) {
		my $score = $viterbi->[(@$observations - 1)]{$state};
		if ($score > $max_score) {
			$max_score = $score;
			$max_state = $state;
		}
	}

	print Dumper $path->{$max_state};

#	print "The most probable path:\n";
#	print join(" ", @{$path->{$max_state}});
#	print "Its probability is $max_score";		
}

