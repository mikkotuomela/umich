#!/usr/bin/perl

use strict;
use File::Slurp;
use CGI qw(:standard);

my $template = read_file('2_4.html');
my $keys     = qw(initials email date time location);

my $locations = ['',
				 'Main Business Office:<br />3075 Clark Rd, Suite 203, Ypsilanti, MI 48197',
				 'Jackson, MI Service Office:<br />211 W Ganson St, Jackson, MI 49201'];
my $times = ['',
			 '9:00 AM - 10:00 AM',
			 '10:00 AM - 11:00 AM',
			 '11:00 AM - 12:00 PM',
			 '12:00 PM - 1:00 PM',
			 '1:00 PM - 2:00 PM'];

my $initials = param('initials');
my $email    = param('email');
my $date     = param('date');
my $time     = param('time');
my $location = param('location');

$template =~ s/%initials%/$initials/;
$template =~ s/%email%/$email/;
$template =~ s/%date%/$date/;
$template =~ s/%time%/$times->[$time]/;
$template =~ s/%location%/$locations->[$location]/;


print "Content-type: text/html\n\n";
print $template;
