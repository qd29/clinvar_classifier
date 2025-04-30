#!/usr/bin/perl -w
use strict;
use Getopt::Std;
my %opts;
getopt ('t:',\%opts);
my $thres=$opts{"t"};

#my @cyc=('1','2');
my @cyc=('1');
open out1, ">./classifier_test_results.txt";
foreach my $cyc (@cyc){
 my %auto;
 open file1, "<./results/variants.$thres.txt";
 while (<file1>){
  chomp;
  my @split1=split /\t/,$_;
  my @split2=split /\|/,$split1[1];
  my $class="Unable"; my $support=0;
  if ($split2[0] eq "LB/B" || $split2[0] eq "VUS"){
   $class="non-LP/P"; $support=1;
  } 
  elsif ($split2[0] eq "LP/P"){
   $class="LP/P"; $support=1;
  }
  for (my $i=1; $i<=$#split2; $i++){
   if ($class eq "non-LP/P"){
    if ($split2[$i] eq "LB/B" || $split2[$i] eq "VUS"){
     $support++;
    }
    else{
     $class="Unable"; $support=0;
    }
   }
   elsif ($class eq "LP/P"){
    if ($split2[$i] eq "LP/P"){
     $support++;
    }
    else{
     $class="Unable"; $support=0;
    }
   }
  }

  if ($class ne "Unable" && $support>=$cyc){
   $auto{$split1[0]}=$class;
  }
 }
 close file1;

 my $ct1=0; my $tot1=0; my $ct2=0; my $tot2=0; my $tot=0;
 open file1, "<./ClinGen_VCEP_curations_grouped.txt";
 while (<file1>){
  chomp;
  my @split1=split /\t/,$_;
  if ($split1[2] eq "Test"){
   my @split2=split /\|/,$split1[1];
   if (exists $auto{$split1[0]}){
    $tot++;
    if ($split2[0] eq "VUS" || $split2[0] eq "LB/B"){
     $tot2++;
     if ($auto{$split1[0]} eq "non-LP/P"){
      $ct2++;
     }
    }
    if ($split2[0] eq "LP/P"){
     $tot1++;
     if ($auto{$split1[0]} eq "LP/P"){
      $ct1++;
     }
    }
   }
  }
 }
 close file1;
 my $rt1="NA";
 if ($tot1>0){
  $rt1=sprintf("%.4f",$ct1/$tot1);
 }
 my $rt2="NA";
 if ($tot2>0){
  $rt2=sprintf("%.4f",$ct2/$tot2);
 }
 print out1 "$thres\t$cyc\t$tot\t$ct1\t$tot1\t$rt1\t$ct2\t$tot2\t$rt2\n";
}
close out1;

exit 0;
