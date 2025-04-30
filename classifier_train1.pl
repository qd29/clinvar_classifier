#!/usr/bin/perl -w
use strict;

my %abv;
$abv{'Likely pathogenic'}='LP/P'; $abv{'Pathogenic'}='LP/P';
$abv{'Uncertain significance'}='VUS';
$abv{'Likely benign'}='LB/B'; $abv{'Benign'}='LB/B';
$abv{'Likely Pathogenic'}='LP/P'; $abv{'Uncertain Significance'}='VUS'; 
$abv{'Likely Benign'}='LB/B';

my @cyc=('01','02','03','04','05','06','07','08','09','10','11','12');
my (%var,%submitter);
for (my $i=2018; $i<=2024; $i++){
 foreach my $cyc (@cyc){
  open file1, "gunzip -c ./by_SCV/ClinVar_by_SCV_$i-$cyc.txt.gz |";
  while (<file1>){
   chomp;
   my @split1=split /\t/,$_;
   my $temp1="$split1[1]|$split1[2]|$split1[3]|$split1[4]";
   if ($split1[6]=~/ClinGen/ && $split1[6]!~/GenomeConnect/){
    my $temp2="$split1[5]|$split1[7]|$split1[9]";
    $submitter{$split1[5]}=$split1[6];
    if (exists $var{$temp1}){
     my @split2=split /\|\|/,$var{$temp1};
     my $iden=0;
     foreach my $split2 (@split2){
      if ($split2 eq $temp2){
       $iden=1;
      }
     }
     if ($iden==0){
      $var{$temp1}="$var{$temp1}||$temp2";
     }
    }
    else{
     $var{$temp1}=$temp2;
    }
   }
  }
  close file1;
  print "Parsed year $i month $cyc ClinVar SCV\n";
 }
}

open out1, ">./ClinGen_VCEP_curations.txt";
foreach my $var (keys %var){
 my @split1=split /\|\|/,$var{$var};
 my (%interp,%SCVinterp,%dateinterp);
 foreach my $split1 (@split1){
  my @split2=split /\|/,$split1;
  my $abv=$split2[2];
  if (exists $abv{$split2[2]}){
   $abv=$abv{$split2[2]};
  }
  else{
   print "CAUTION $split1 classification does not fit into the 5-tier system\n";
  }
  my @split4=split /\-/,$split2[1];
  my $temp3="$split4[0]$split4[1]$split4[2]";
  if (!exists $dateinterp{$abv}){
   $dateinterp{$abv}=$temp3;
  }
  elsif ($temp3>$dateinterp{$abv}){
   $dateinterp{$abv}=$temp3;
  }

  if (exists $interp{$abv}){
   $interp{$abv}="$interp{$abv},$split2[1]";
   my @split3=split /\,/,$SCVinterp{$abv};
   my $iden=0;
   foreach my $split3 (@split3){
    if ($split3 eq $split2[0]){
     $iden=1;
    }
   }
   if ($iden==0){
    $SCVinterp{$abv}="$SCVinterp{$abv},$split2[0]";
   }
  }
  else{
   $interp{$abv}=$split2[1];
   $SCVinterp{$abv}=$split2[0];
  }
 }

 print out1 "$var";
 my %revdateinterp=reverse %dateinterp;
 my @revdateinterp=keys %revdateinterp;
 @revdateinterp=sort{$b<=>$a}@revdateinterp;
 foreach my $revdateinterp (@revdateinterp){
  my @split5=split /\,/,$SCVinterp{$revdateinterp{$revdateinterp}};
  my $temp4=$submitter{$split5[0]};
  for (my $i=1; $i<=$#split5; $i++){
   $temp4="$temp4,$submitter{$split5[$i]}";
  }
  print out1 "\t$revdateinterp{$revdateinterp}|$temp4|$SCVinterp{$revdateinterp{$revdateinterp}}|$interp{$revdateinterp{$revdateinterp}}";
 }
 print out1 "\n";
}
close out1;

system ("perl ./classifier_train2.pl; perl ./classifier_train3.pl; perl ./classifier_train4.pl; perl ./classifier_train5.pl");
my @cyc2=("0.800","0.825","0.850","0.875","0.900","0.925","0.950");
foreach my $cyc2 (@cyc2){
 system ("perl ./classifier_train6.pl -t $cyc2");
 system ("perl ./classifier_train7.pl -t $cyc2");
}

exit 0;
