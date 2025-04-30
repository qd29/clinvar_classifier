#!/usr/bin/perl -w
use strict;
use Getopt::Std;
my %opts;
getopt ('t:',\%opts);
my $thres=$opts{'t'};

my %abv;
$abv{'Likely pathogenic'}='LP/P'; $abv{'Pathogenic'}='LP/P';
$abv{'Uncertain significance'}='VUS';
$abv{'Likely benign'}='LB/B'; $abv{'Benign'}='LB/B';
$abv{'Likely Pathogenic'}='LP/P'; $abv{'Uncertain Significance'}='VUS';
$abv{'Likely Benign'}='LB/B';

my (%subp,%subb);
open file1, "<./ClinVar_train_results.txt";
while (<file1>){
 chomp;
 my @split1=split /\t/,$_;
 unless ($split1[0]=~/Mayo/){ # excludes Mayo
  if ($split1[6]>=$thres){
   $subp{$split1[0]}=1;
  } 
  if ($split1[9]>=$thres){
   $subb{$split1[0]}=1;
  }
 }
}
close file1;

open file1, "gunzip -c ./by_SCV/ClinVar_by_SCV_2024-12.txt.gz |";
my (%var,%varp,%varb);
while (<file1>){
 chomp;
 my @split1=split /\t/,$_;
 my $temp1="$split1[1]|$split1[2]|$split1[3]|$split1[4]";
 if (exists $subp{$split1[6]} && exists $subb{$split1[6]} && exists $abv{$split1[9]}){
  $var{$temp1}=1;
  if (exists $varp{$temp1}){
   $varp{$temp1}="$varp{$temp1}|$abv{$split1[9]}";
  }
  else{
   $varp{$temp1}=$abv{$split1[9]};
  }
 }
}
close file1;

open out1, ">./classification_temp.txt";
my @var=keys %var;
@var=sort @var;
foreach my $var (@var){
 my $varp="NA";
 if (exists $varp{$var}){
  $varp=$varp{$var};
 }
 print out1 "$var\t$varp\n";
}
close out1;

open file1, "<./classification_temp.txt";
open out1, ">./classification_results.txt";
while (<file1>){
 chomp;
 my @split1=split /\t/,$_;
 my @split2=split /\|/,$split1[1];
 my @split3=@split2;
 my $autoclass="Unable";
 my $st2_lpp=0; my $st2_nonlpp=0;
 foreach my $split2 (@split2){
  if ($split2 eq "LP/P"){
   $st2_lpp++;
  }
  elsif ($split2 eq "VUS" || $split2 eq "LB/B"){
   $st2_nonlpp++;
  }
 }

 if ($st2_lpp>0 && $st2_nonlpp==0){
  $autoclass="LP/P";
 }

 my $st3_lpp=0; my $st3_nonlpp=0;
 foreach my $split3 (@split3){
  if ($split3 eq "VUS" || $split3 eq "LB/B"){
   $st3_nonlpp++;
  }
  elsif ($split3 eq "LP/P"){
   $st3_lpp++;
  }
 }

 if ($st3_nonlpp>0 && $st3_lpp==0){
  if ($autoclass eq "Unable"){
   $autoclass="non-LP/P";
  }
  else{
   $autoclass="Unable";
  }
 }
 if ($autoclass ne "Unable"){
  my @split4=split /\|/,$split1[0];
  if ($split4[0] ne "Un"){
   print out1 "$split4[0]\t$split4[1]\t$split4[2]\t$split4[3]\t$autoclass\n";
  }
 }
}
close file1;
close out1;
system ("rm -f ./classification_temp.txt");

exit 0;
