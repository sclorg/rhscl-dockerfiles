#!/usr/bin/perl
print "Content-type: text/plain\n\n";
my $output = `ipcount 2>&1`;
if (!defined $output) {
    die "No output from `ipcount' command";
}
print $output;
