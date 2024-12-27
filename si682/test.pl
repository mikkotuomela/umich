#!/usr/bin/perl -w

use strict;
use File::Slurp;
use Data::Dumper;
use CGI qw(:standard);

use constant TEMPLATE => 'template.html';
use constant MAX      => 7;

my $questions = [
    "In the last three months, have you had unprotected vaginal, anal or oral sex with anyone whose HIV status you didn.t know, or whose status is different than yours?",
    "Have you had a sexually transmitted disease within the past five years, such as Chlamydia, human papilloma virus (genital warts), gonorrhea, syphilis, herpes, or hepatitis A, B, or C?",
    "Are any of your current or past sex partners HIV positive?",
    "Have you ever exchanged sex for money, drugs, alcohol or a place to stay or have you ever paid a person to have sex?",
    "Do you use drugs or alcohol before or during sex?",
    "Have you ever used a needle to inject drugs into your veins or under your skin, including steroids?",
    "Have any of your current or past sex partners ever injected drugs into their veins or under their skin, including steroids?",
#    "In the last three months, have you had unprotected vaginal, anal or oral sex with anyone whose HIV status you didn.t know, or whose status is different than yours?",
#    "Have you had a sexually transmitted disease within the past five years, such as Chlamydia, human papilloma virus (genital warts), gonorrhea, syphilis, herpes, or hepatitis A, B, or C?",
#    "Are any of your current or past sex partners HIV positive?",
#    "Have you ever exchanged sex for money, drugs, alcohol or a place to stay or have you ever paid a person to have sex?",
#    "Do you use drugs or alcohol before or during sex?",
#   "Have you ever used a needle to inject drugs into your veins or under your skin, including steroids?",
#    "Have any of your current or past sex partners ever injected drugs into their veins or under their skin, including steroids?"
];

{
    print header;
    my $nq = scalar(@$questions);
    my $page = param('p');
    $page = 1 unless defined $page;
    $page -= 2 if param('prev');

	my $res = param("res");
	my $dd  = param("dd");

    my $content = "";
    my $total_pages = int(scalar @$questions / (MAX + 1)) + 1;

    if ($page <= $total_pages) {
		$content .= h1("Page $page of $total_pages");
		$content .= "<table>\n";
		
		# Go through all questions
		my $firstq = ($page-1) * MAX;
		my $lastq  = $firstq + MAX - 1;
		foreach my $q ($firstq .. $lastq) {
			next unless defined $questions->[$q];
			my $r = $q + 1;
			$content .= "<tr><td class=\"question\"><strong>Question $r:</strong> $questions->[$q]</td>\n";
			
			if (!$dd) {
				$content .= "<td class=\"answer\"><input type=\"radio\" name=\"q$q\" value=\"1\" id=\"yes$q\" /> <label for=\"yes$q\">Yes</label> \n";
				$content .= "<input type=\"radio\" name=\"q$q\" value=\"0\" id=\"no$q\" /> <label for=\"no$q\">No</label></td></tr>\n";
			} else {
				$content .= "<td class=\"answer\"><select name=\"q$q\"><option value=\"0\">--- Choose answer</option><option value=\"1\">Yes</option><option value=\"0\">No</option></select></td></tr>\n";
			}
		}
		$content .= "</table>\n";
		
		# Buttons
		$content .= "<p class=\"buttons\">";
		$content .= "<input type=\"submit\" value=\"Previous page\" name=\"prev\" />"
			if $page > 1;
		$content .= "<input type=\"submit\" value=\"Next page\" name=\"next\" />" 
			if $page < $total_pages;
		
		$content .= "<input type=\"submit\" value=\"See results\" />" 
			if $page == $total_pages;
		$content .= "</p>\n";
		
		$page++;
		$content .= "<input type=\"hidden\" value=\"$dd\" name=\"dd\" />";
		$content .= "<input type=\"hidden\" value=\"$res\" name=\"res\" />";
		$content .= "<input type=\"hidden\" value=\"$page\" name=\"p\" />";
		$content .= "<input type=\"hidden\" value=\"". $nq . "\" name=\"n\" />";
		
		for my $i (1 .. $nq) {
			my $value = param("q$i");
			next unless defined $value;
			$content .= "<input type=\"hidden\" name=\"q$i\" value=\"$value\" />\n";
			
		}
		
    } else {
		
		my $result = 0;
		for my $i (1 .. $nq) {
			$result++ if param("q$i") eq '1';
		}
		
		$content .= p("<b>Risk Assessment Test result</b>");
		$content .= p("You answered \'yes\' to $result of $nq questions.");
		
		my $risk = "";
		$risk = "low"          if $result == 0;
		$risk = "intermediate" if $result > 0 and $result < 3;
		$risk = "high"         if $result > 2;
		
		my $color = {
			low => 'orange',
			intermediate => 'yellow',
			high => 'red',
		};

		# Print results
		if ($res == 1) {
			$content .= p("Based on this score, you are at $risk risk for HIV. We recommend you to schedule a testing appointment at HARC.");			
		} elsif ($res == 2) {
			my $curcolor = $color->{$risk};
			$content .= p("Based on this score, you are at <b style=\"background-color:$curcolor;color:white\">$risk</b> risk for HIV. We recommend you to schedule a testing appointment at HARC.");			
		}
		$content .= p("<input type=\"submit\" value=\"Schedule a testing appointment\" />") unless $risk eq 'low';
		
		$content .= p("This is not a medical diagnosis, but you may want further information on prevention and HIV testing. Consider the following resources:");
		$content .= p("<a href=\"http://hivaidsresource.org/hiv-testing/hiv-testing/\">HIV Testing, Counseling, and Referral</a>");
		$content .= p("<a href=\"http://hivaidsresource.org/hiv-aids-prevention-education-and-training/related-links-resources/\">Other HIV/AIDS Related Resources</a>");
	    
    }

    my $template = read_file(TEMPLATE);
    $template =~ s/%content%/$content/;
    print $template;
}
