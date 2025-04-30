#!/usr/bin/perl -w
use strict;
srand(1000);
use List::Util qw(shuffle);

open file1, "<./ClinVar_curations_before_ClinGen.txt";
my %in;
while (<file1>){
 chomp;
 my @split1=split /\t/,$_;
 $in{$split1[1]}=1;
}
close file1;

open file1, "<./ClinGen_VCEP_curations.txt";
my %clingen;
while (<file1>){
 chomp;
 my @split1=split /\t/,$_;
 if ($#split1==1){
  my @split2=split /\|/,$split1[1];
  if (exists $in{$split1[0]} && ($split2[0] eq "VUS" || $split2[0] eq "LP/P" || $split2[0] eq "LB/B")){
   $clingen{$split1[0]}=$split1[1];
  }
 }
}
close file1;

my @clingen=keys %clingen;
@clingen=sort(@clingen);
@clingen=shuffle(@clingen);

open out1, ">./ClinGen_VCEP_curations_grouped.txt";
foreach my $clingen (@clingen){
 my $rand=rand(1);
 my $st="Train";
 if ($rand>=0.8){
  $st="Test";
 }
 print out1 "$clingen\t$clingen{$clingen}\t$st\n";
}
close out1;

open file1, "<./ClinVar_curations_before_ClinGen.txt";
my %ct;
while (<file1>){
 chomp;
 my @split1=split /\t/,$_;
 if (exists $clingen{$split1[1]}){
  $ct{$split1[2]}++;
 }
}
close file1;

my %ct2;
foreach my $ct (values %ct){
 $ct2{$ct}=1;
}
my @ct=keys %ct2;
@ct=sort{$b<=>$a}@ct;
open out1, ">./ClinVar_submitters_ClinGen_variants.txt";
foreach my $ct (@ct){
 foreach my $keys (keys %ct){
  if ($ct{$keys} eq $ct){
   print out1 "$keys\t$ct\n";
  }
 }
}
close out1;

exit 0;
