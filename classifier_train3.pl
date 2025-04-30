#!/usr/bin/perl -w
use strict;

my %abv;
$abv{'Likely pathogenic'}='LP/P'; $abv{'Pathogenic'}='LP/P';
$abv{'Uncertain significance'}='VUS';
$abv{'Likely benign'}='LB/B'; $abv{'Benign'}='LB/B';
$abv{'Likely Pathogenic'}='LP/P'; $abv{'Uncertain Significance'}='VUS';
$abv{'Likely Benign'}='LB/B';

my %oldest;
open file1, "<./ClinGen_VCEP_curations.txt";
while (<file1>){
 chomp;
 my @split1=split /\t/,$_;
 my $min=1e20;
 for (my $i=1; $i<=$#split1; $i++){
  my @split2=split /\|/,$split1[$i];
  my @split3=split /\,/,$split2[3];
  foreach my $split3 (@split3){
   my @split4=split /\-/,$split3;
   my $temp1="$split4[0]$split4[1]$split4[2]";
   if ($temp1<$min){
    $min=$temp1;
   }
  }
 }
 $oldest{$split1[0]}=$min;
}
close file1;

open file1, "<./ClinVar_curations_ClinGen_variants.txt";
open out1, ">./ClinVar_curations_before_ClinGen.txt";
while (<file1>){
 chomp;
 my @split1=split /\t/,$_;
 if (exists $oldest{$split1[1]}){
  my @split2=split /\|\|/,$split1[3];
  my %date;
  foreach my $split2 (@split2){
   my @split4=split /\|/,$split2;
   my @split3=split /\-/,$split4[0];
   my $temp2="$split3[0]$split3[1]$split3[2]";
   if (exists $abv{$split4[1]} && $temp2<$oldest{$split1[1]}){
    $date{$temp2}=$abv{$split4[1]};
   }
  }
  my @date=keys %date;
  @date=sort{$b<=>$a}@date;
  if ($date[0]){
   my $sub1=substr $date[0],0,4;
   if ($sub1>=2018){
    print out1 "$split1[0]\t$split1[1]\t$split1[2]\t$date[0]\t$date{$date[0]}\n";
   }
  }
 }
}
close file1;
close out1;

exit 0;
