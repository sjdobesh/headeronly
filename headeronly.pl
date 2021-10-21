#!/usr/bin/perl
#==========================================================#
#     __                   __                      __      #
#    / /_  ___  ____ _____/ /__  _________  ____  / /_  __ #
#   / __ \/ _ \/ __ `/ __  / _ \/ ___/ __ \/ __ \/ / / / / #
#  / / / /  __/ /_/ / /_/ /  __/ /  / /_/ / / / / / /_/ /  #
# /_/ /_/\___/\__,_/\__,_/\___/_/   \____/_/ /_/_/\__, /   #
#                                                /____/    #
#==========================================================#
# Author: Sam Dobesh                                       #
# Date: Oct 21st 2021                                      #
# Desc: Take a C module and convert to a header only file  #
# to include. Module must be corresponding x.c && x.h, and #
# the header must be wrapped in a #ifndef _X_H_.           #
#==========================================================#
# Usage:                                                   #
#   ./headeronly.pl [file.c] [file.h]                      #
#                                                          #
# x.c is the implementation file.                          #
# x.h is the associated header file.                       #
#==========================================================#==================80

use strict;
use warnings;
use Cwd;
use Cwd 'abs_path';

# PARSING INPUT #--------------------------------------------------------------
# evaluate flags and inputs, spit out usage if error parsing

my $argc = $#ARGV + 1;
if ($argc != 2) {
  print "Error parsing arguments.\n";
  print "Usage: ./headeronly.pl [file.c] [file.h]\n";
  exit -1;
}

# right number of args so read them in
my $c = $ARGV[0];
my $h = $ARGV[1];

# adjust any paths to abs
$c = abs_path($c);
$h = abs_path($h);

# snip off file names for later
my $include = get_include_name($c);

# open up a new file to dump lines into
open(HEADER, '>', "headeronly.h") or die $!;
open(DOTC, '<', $c);
open(DOTH, '<', $h);

# print all but the closing endif of the header
while(<DOTH>) {
  if (not ($_ eq "#endif")) {
    print HEADER $_;
  }
}
print HEADER "/* beginning implementation code */";
# print all but the header include statement
while(<DOTC>) {
  if (not ($_ eq $include)) {
    print HEADER $_;
  }
}
# print closing endif
print HEADER "#endif";

close(HEADER);
close(DOTC);
close(DOTH);

sub get_include_name {
  my $path = @_;
  $path =~ s{^.*/}{};
  return "#include \"".$path."\"";
}
