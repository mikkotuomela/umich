#!/usr/bin/perl
#
# Mikko Tuomela <mstuomel@umich.edu>
# SI 544: Introduction to Statistics and Data Analysis

use strict;
use IP;
#use IP::Country::DNSBL;
use Locale::Country;

#my $line = 'Nov 22 08:05:58 oceanide postfix/smtpd[15464]: connect from unknown[110.139.65.23]';
#my $line = 'Nov 22 08:05:58 oceanide postfix/smtpd[15464]: connect from unknown[4.4.4.4]';

# Go through all input
{
	my $countries = { };
	my $total     = 0;
	my $spam      = 0;
	my $known     = 0;
	my $gi        = IP->new(1);

	# Loop until input ends
	while (<>) {

		$total++; # count emails
		next if $_ =~ /facebook\.com/;
		next if $_ =~ /umich\.edu/;
		next if $_ =~ /linkedin\.com/;
		next if $_ =~ /ieee.org/;
		next if $_ =~ /.fi\[/;

		my $ip      = get_ip($_);
#		next if $ip =~ /unknown/;

		$spam++;

		my $code           = $gi->country_code_by_addr($ip);
		my $country_string = get_country_string($code);

		if ($country_string) {
			$countries->{$code}++;
			$known++;
		}
		print "$ip\t$country_string\n";
	}

	# Sort the results by number
	my @sc = sort { $countries->{$b} <=> $countries->{$a} } keys %$countries;

	# Write results
	open(OUT, ">results.txt") or die "$!";
	print OUT "Total emails:  $total\n";
	print OUT "Spam emails:   $spam\n";
	print OUT "Country known: $known\n\n";
	my $n = 1;
	foreach my $code (@sc) {
		print OUT $n . '. ' . get_country_string($code). " - " 
			. $countries->{$code} . "\n";
		$n++;
	}
	close OUT;
}

sub get_country_string {
	my ($code) = @_;
	my $country = code2country(lc($code));
	return $country ? "$code ($country)" : '';
}

# Clean exit
exit 1;

# Filter IP address from the log line
sub get_ip {
	my ($line) = @_;
	chomp($line);
	my $res = substr($line, -17);
	$res = substr($res, 0, length($res) - 1);	
	for my $i (0 .. length($res)) {
		next unless substr($res, $i, 1) > 0;
		$res = substr($res, $i, length($res) - $i);
		last;
	}
	return $res;
}
