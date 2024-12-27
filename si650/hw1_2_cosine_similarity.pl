#!/usr/bin/perl -wT
#
# SI 650: Information Retrieval
# Mikko Tuomela <mstuomel@umich.edu>

use strict;
use Text::Document;

{
    my $q  = create_doc('comput informat');
    my $d1 = create_doc('school informat');
    my $d2 = create_doc('school informat comput');
    my $d3 = create_doc('school informat library science');

    print "Cosine similarity:\n";
    print "d1: " . $q->CosineSimilarity($d1) . "\n";
    print "d2: " . $q->CosineSimilarity($d2) . "\n";
    print "d3: " . $q->CosineSimilarity($d3) . "\n";
}


sub create_doc {
    my ($text) = @_;
    my $doc = Text::Document->new();
    $doc->AddContent($text);
    return $doc;
}
