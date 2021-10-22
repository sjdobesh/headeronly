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
# the header must be wrapped in a #ifndef _FILE_H_.        #
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

# snip off file names for include statement
my $include = $c;
$include =~ s{^.*/}{};
my $outputname = $h;
$outputname =~ s{^.*/}{};
$outputname = "headeronly-" . $outputname;


$include = "#include \"" . $include . "\"";

# open up a new file to dump lines into
open(HEADER, '>', $outputname) or die $!;
open(DOTC, '<', $c);
open(DOTH, '<', $h);

# print all but the closing endif of the header
while(my $line = <DOTH>) {
  if (not ($line eq "#endif")) {
    print HEADER $line;
  }
}

print HEADER "/* beginning implementation code */";

# print all but the header include statement and main()
while(my $line = <DOTC>) {
  if ($line =~ /int main/){
    # count occurences
    my $countup = () = $line =~ /{/g;
    my $countdown = () = $line =~ /}/g;
    my $stack = $countup + $countdown;
    # while we have unmatched brackets
    while ($stack > 0) {
      $line = <DOTC>;
      $countup = () = $line =~ /{/g;
      $countdown = () = $line =~ /}/g;
      $stack = $stack + $countup;
      $stack = $stack - $countdown;
    }
  }
  elsif (not $line eq $include) {
    print HEADER $line;
  }
}

# append closing endif
print HEADER "#endif";

# close all files
close(HEADER);
close(DOTC);
close(DOTH);
