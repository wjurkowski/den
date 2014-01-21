#!/usr/bin/perl

use strict;
use warnings;
use Cwd;
use FileHandle;


##############################################################################################################
###Script for extracting consistent interactions from network file based on file containing list of DEPs.   ##
##Both input files need the same type of Identifiers for the proteins, for example SwissProt, Gene Symbols, ##
##EntrezGene IDs  											    ##

#Two ypes of output:
#	validated-* list of nodes verified positively after comparison of node connectivity with  expression state (up, down or undetermined)
#	D-*	positively verified subnetwork for given time point (one if no time series data are available)
#	H-* the same for "healty" state netowork
##############################################################################################################


#################Directories and input files need to be adapted#################
#Current directory:
my $dir= getcwd();

if ($#ARGV != 2) {die "Program used with parameters [network] [expression pattern] [network type]\n";}

my $file_net_input = $ARGV[0];
my $file_SignifProteins = $ARGV[1];
my $nettype=$ARGV[2];
if (($nettype ne "H") and ($nettype ne "D")) {die "Wrong network type";}
my $file_net_output =  "validated_". $nettype. "-" . $file_net_input;
################################################################################



###############
##DEP parser:##
###############

#Hash for storing differential expression patterns of proteins this means
#if induced (+1), repressed (-1), or not differentially expressed (0):
my %H_ProteinIdentifier2SignifT;


open( FH, "$dir/$file_SignifProteins" )
  or die "Cannot open $dir/$file_SignifProteins: $!";

while (<FH>) {

	my $Line = $_;
	chomp($Line);

	my @A_Line = split /\t/, $Line;
	if($nettype eq "H"){	
		$H_ProteinIdentifier2SignifT{ $A_Line[0] }{"1"} = -$A_Line[1];
		$H_ProteinIdentifier2SignifT{ $A_Line[0] }{"2"} = -$A_Line[2];
		$H_ProteinIdentifier2SignifT{ $A_Line[0] }{"3"} = -$A_Line[3];
	}
	elsif($nettype eq "D"){
		$H_ProteinIdentifier2SignifT{ $A_Line[0] }{"1"} = $A_Line[1];
		$H_ProteinIdentifier2SignifT{ $A_Line[0] }{"2"} = $A_Line[2];
		$H_ProteinIdentifier2SignifT{ $A_Line[0] }{"3"} = $A_Line[3];
	}
}

close FH;




###################
##Network parser:##
###################

open( FH, "$dir/$file_net_input" ) or die "Cannot open $file_net_input: $!";

open( WH, ">$dir/$file_net_output" ) or die "Cannot open $file_net_output: $!";
my @handles;
for (my $k=1; $k<4; $k++){
	local *FILE;
	my $file=$nettype."-TP".$k."-". $file_net_input;
	open(FILE, ">$dir/$file") or die "Cannot open $file: $!";	
	#my $TP = FileHandle -> new(">$dir/$file") or die "Cannot open $verified_net1: $!";
	push (@handles,*FILE);
}

print WH "Time-point\tRegulatory_Pattern_DEPs\tEntrezGene_A\tEntrezGene_B\tRegulatory_effect_Interaction\n";

while (<FH>) {

	my $Line = $_;
	chomp($Line);

	my @A_Line = split /\t/, $Line;
	
	my $Node_1 = $A_Line[0];
	my $Node_2 = $A_Line[2];
	my ($Interaction) = $A_Line[1]=~/\(([-+|>]{4})\)/;
	
	next unless(defined($Interaction));
	
	my $Reg_Pat;
	
	$Reg_Pat = "Pos" if($Interaction=~/\+/);
	$Reg_Pat = "Neg" if($Interaction=~/\|/);
	$Reg_Pat = "ND"	unless($Interaction=~/[+|]/);


	#Iterating over the three time points and checking the validity of the interactions (separately):
	for(my $i=1; $i<4; $i++){
		my $handle = $handles[$i-1];
		#When no DEP at all implicated in interactions:
		next unless(defined($H_ProteinIdentifier2SignifT{ $Node_1 }{$i}) and defined($H_ProteinIdentifier2SignifT{ $Node_2 }{$i}));
#		next if(($H_ProteinIdentifier2SignifT{ $Node_1 }{$i}==0) and (($H_ProteinIdentifier2SignifT{ $Node_2 }{$i})==0));

		my $Sum=0;

		$Sum +=	$H_ProteinIdentifier2SignifT{ $Node_1 }{$i};
		$Sum +=	$H_ProteinIdentifier2SignifT{ $Node_2 }{$i};
				
		$H_ProteinIdentifier2SignifT{ $Node_1 }{$i} . "\t" . $H_ProteinIdentifier2SignifT{ $Node_2 }{$i} . "\n"; 
				
				
		#We keep the non defined regulatory interactions all in:
		if($Reg_Pat eq "ND"){
			print WH $i . "\t" . $Sum . "\t" . $Node_1 . "\t" . $Node_2 . "\t" .  $Reg_Pat . "\n";
			print $handle $Node_1 . "\t" . $Interaction . "\t" . $Node_2 . "\n";
			
		}
		#...when only one node has identified state:
		elsif( abs($Sum) == 1 ){
			#A0 --+> B1 we keep only positive
			if(($H_ProteinIdentifier2SignifT{ $Node_2 }{$i} == 1) && ($Reg_Pat eq "Pos")){
				print WH $i . "\t" . $Sum . "\t" . $Node_1 . "\t" . $Node_2 . "\t" .  $Reg_Pat . "\n";
				print $handle $Node_1 . "\t" . $Interaction . "\t" . $Node_2 . "\n";
			}
			#A0 ---| B-1 we keep only negative
			elsif(($H_ProteinIdentifier2SignifT{ $Node_2 }{$i} == -1) && ($Reg_Pat eq "Neg")){
                                print WH $i . "\t" . $Sum . "\t" . $Node_1 . "\t" . $Node_2 . "\t" .  $Reg_Pat . "\n";
				print $handle $Node_1 . "\t" . $Interaction . "\t" . $Node_2 . "\n";
                        }
			#We keep all interactions in if the receiver is B0:
			elsif($H_ProteinIdentifier2SignifT{ $Node_2 }{$i} == 0){
                                print WH $i . "\t" . $Sum . "\t" . $Node_1 . "\t" . $Node_2 . "\t" .  $Reg_Pat . "\n";
				print $handle $Node_1 . "\t" . $Interaction . "\t" . $Node_2 . "\n";
                        }		
		} 
		# ... when both interacting partners show an induced regulatory pattern (+1/+1 )
		elsif( ($Sum == 2) && ($Reg_Pat eq "Pos") ){		
		#we keep those which are linked by a regulatory interaction with positive effect:
			print WH $i . "\t" . $Sum . "\t" . $Node_1 . "\t" . $Node_2 . "\t" .  $Reg_Pat . "\n";	
			print $handle $Node_1 . "\t" . $Interaction . "\t" . $Node_2 . "\n";
		} 
		# ... when both interacting partners show a repressed  regulatory pattern (-1/-1 )
		elsif( $Sum == -2 ){
		#we keep interactions in which two partners are down-regulated and one is repressing or activating the other
			print WH $i . "\t" . $Sum . "\t" . $Node_1 . "\t" . $Node_2 . "\t" .  $Reg_Pat . "\n";
			print $handle $Node_1 . "\t" . $Interaction . "\t" . $Node_2 . "\n";
		} 
		# ... when both partners have opposite regulatory patterns(+1/-1 or -1/+1)	
		elsif( $Sum==0 ){
			#... the regulatory pattern of their interaction needs to be negative to be validated (one protein inhibits the other):
			if($Reg_Pat eq "Neg"){
				print WH $i . "\t" . $Sum . "\t" . $Node_1 . "\t" . $Node_2 . "\t" .  $Reg_Pat . "\n";
				print $handle $Node_1 . "\t" . $Interaction . "\t" . $Node_2 . "\n";
			}
		} 

	}
}


close FH;
