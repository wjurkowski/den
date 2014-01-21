#!/usr/bin/perl -w

use strict;
use warnings;

if ($#ARGV != 3) {die "Program used with parameters [motifs] [upregulated] [downregulated]\n";}

my @motifs=open_file($ARGV[0]);
my @upregi=open_file($ARGV[1]);
my @downregi=open_file($ARGV[2]);
my $mottype=$ARGV[3];

foreach my $lin(@motifs){
	my ($mot,$gen);
	my $g1=2;
	my $g2=2;
	my $g3=2;
	my $state="UNVALID";
	my @tab=split(/\s+/,$lin);
	foreach $gen(@upregi){
		if($tab[1] eq $gen) {$g1=1;}
		if($tab[2] eq $gen) {$g2=1;}
		if($tab[3] eq $gen) {$g3=1;}
	}
	foreach $gen(@downregi){
        	if($tab[1] eq $gen) {$g1=0;}
        	if($tab[2] eq $gen) {$g2=0;}
        	if($tab[3] eq $gen) {$g3=0;}
	}
	if($mottype==301){
		if(($g1==1) && ($g2==1) && ($g3 ==1)){$state="VALID";}
		if(($g1==0) && ($g2==0) && ($g3 ==0)){$state="VALID";}
		if(($g1==2) || ($g2==2) || ($g3 ==2)){$state="UNCERTAIN";}
	}
	if($mottype==302){
		if(($g1==1) && ($g2==1) && ($g3 ==0)){$state="VALID";}
		if(($g1==0) && ($g2==0) && ($g3 ==0)){$state="VALID";}
		if(($g1==2) || ($g2==2) || ($g3 ==2)){$state="UNCERTAIN";}
	}
	if($mottype==303){
		if(($g1==1) && ($g2==1) && ($g3 ==0)){$state="VALID";}
		if(($g1==0) && ($g2==0) && ($g3 ==1)){$state="VALID";}
		if(($g1==2) || ($g2==2) || ($g3 ==2)){$state="UNCERTAIN";}
	}
	if($mottype==304){
		if(($g1==1) && ($g2==0) && ($g3 ==1)){$state="VALID";}
		if(($g1==0) && ($g2==0) && ($g3 ==0)){$state="VALID";}
		if(($g1==2) || ($g2==2) || ($g3 ==2)){$state="UNCERTAIN";}
	}
	print "$lin\t$state\t$mottype\t$g1\t$g2\t$g3\n"; 
}

sub open_file{
        my ($file_name)=@_;
        open(INP1, "< $file_name") or die "Can not open an input file: $!";
        my @file1=<INP1>;
        close (INP1);
        chomp @file1;
        return @file1;
}

