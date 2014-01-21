#!/usr/bin/perl -w
use strict;
use warnings;
use Bipartite;

if ($#ARGV < 0 ) {die "Run type available \
-n normal mode\
-s single node removal\
-p pairwise node removal\n";
}
if (($ARGV[0] eq "-n") and ($#ARGV != 1)) {die "Program runs with parameters! [run type ][list of network edges]\n";}
elsif (($ARGV[0] eq "-s") and ($#ARGV != 2)) {die "Program runs with parameters! [run type ][list of network edges] [node]\n";}
elsif (($ARGV[0] eq "-p") and ($#ARGV != 3)) {die "Program runs with parameters! [run type ][list of network edges] [node1] [node2]\n";}
#else {die "$ARGV[0] Wrong run parameter";}

open(NET, "<$ARGV[1]");
my $outf=substr($ARGV[1],0,rindex($ARGV[1],"."))."-um.txt";
open(OUTPUT,">>$outf");
my @network_lines = <NET>;
close NET;
my %v1=();
my %v2=();
my %v1_reverse=();
my %v2_reverse=();

my $counter_v1 =0;
foreach my $line(@network_lines){
	if ($line =~ /(\w+\-*\w*)(\s)(\-[\>\|])(\s)(\w+\-*\w*)/){
		if (exists $v1{$1}){}
		else {
			$v1{$1}= $counter_v1;
			$v1_reverse{$counter_v1}=$1;
			$counter_v1++;
		}
		
	}
	else{}
}
my $counter_v2 =$counter_v1;
foreach my $line(@network_lines){
	if ($line =~ /(\w+\-*\w*)(\s)(\-[\>\|])(\s)(\w+\-*\w*)/){
		if (exists $v2{$5}){}
		else {
			$v2{$5}= $counter_v2;
			$v2_reverse{$counter_v2}=$5;
			$counter_v2++;
		}
		
	}
	else{}
}
my $v1_size=scalar keys %v1;
my $v2_size=scalar keys %v2;
my $g = Bipartite->new($v1_size , $v2_size);

foreach my $line(@network_lines){
	if ($line =~ /(\w+\-*\w*)(\s)(\-[\>\|])(\s)(\w+\-*\w*)/){
		$g->insert_edge( $v1{$1}, $v2{$5});
	}
	else{}
}

my %h = $g->maximum_matching();

#foreach my $key(keys %h){
	#print "$key : $h{$key}\n";
	#print $v1_reverse{$key}." : ".$v2_reverse{$h{$key}}."\n";
	
#}	
foreach my $key(keys %h){
	#print "$key : $h{$key}\n";
	print $v1_reverse{$key}." -> ".$v2_reverse{$h{$key}}."\n";
}	
	my $size =keys %h; 	
if($ARGV[0] eq "-n"){
	print "get number of matching edges\n";
	my $ndriver_nodes= 102 - $size;
	print OUTPUT "$ndriver_nodes\n";
}
elsif($ARGV[0] eq "-s"){
	print "get critical number of nodes after single node removal\n";
	my $ndriver_nodes= 102 -1 - $size;
	my $density=$ndriver_nodes/(102 -2);
	print OUTPUT "$ARGV[2]\t$size\t$ndriver_nodes\t$density\n";
}
elsif($ARGV[0] eq "-p"){
	print "get number of critical nodes after pairwise node removal\n";
	my $ndriver_nodes= 102 -2 - $size;
	my $density=$ndriver_nodes/(102 -2);
	print OUTPUT "$ARGV[2]\t$ARGV[3]\t$size\t$ndriver_nodes\t$density\n";
}
#else{
#	print OUTPUT "$size\n";
#}

