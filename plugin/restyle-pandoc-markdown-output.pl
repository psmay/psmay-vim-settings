#! /usr/bin/perl

# Tacky script for removing some of the hateful "upgrades" applied by pandoc
# when formatting markdown.

use warnings;
use strict;
use 5.010;
use Carp;

while(<>) {
	chomp;
	# Use stars for lists
	s/^((?:    )*)-(   )/$1*$2/g;
	# Kill excessive backslashes
	s/\\([<>&;*#~_$])/$1/g;
	say;
}
