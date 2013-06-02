#!/usr/bin/perl
use strict;
use warnings;

my $string = "/media/inline/imported/mind-in-motion_2.jpg";
$string =~ s/.+?imported\///g;
print $string,"\n";