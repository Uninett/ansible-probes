#!/usr/bin/perl

use Scalar::Util qw(looks_like_number);

open(my $fh,"<","/root/scripts/probe.name");
$name=<$fh>;
chop($name);

open(my $fh,"<","/root/scripts/probe_id.txt");
$id=<$fh>;
chop($id);


$time=time;

while(<>) {
    if(!/nan/) {
    /(^\S+) (.*)$/;
    if ( looks_like_number($2)) {
        print "$1,probe=$name,id=$id value=$2 ".$time."000000000\n";
    } else {
    	# print "$2,probe=$name valeu=0,msg=$3 ".$time."000000000\n";
    }
    }
}
