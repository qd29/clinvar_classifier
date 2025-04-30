#!/usr/bin/perl -w
use strict;

my %invar;
open file1, "<./ClinGen_VCEP_curations.txt";
while (<file1>){
 chomp;
 my @split1=split /\t/,$_;
 $invar{$split1[0]}=1;
}
close file1;

my @cyc=('01','02','03','04','05','06','07','08','09','10','11','12');
my (%pos,%var,%submitter);
for (my $i=2018; $i<=2024; $i++){
 foreach my $cyc (@cyc){
  open file1, "gunzip -c ./by_SCV/ClinVar_by_SCV_$i-$cyc.txt.gz |";
  while (<file1>){
   chomp;
   my @split1=split /\t/,$_;
   my $temp1="$split1[1]|$split1[2]|$split1[3]|$split1[4]";
   if (exists $invar{$temp1} && uc($split1[7]) ne "NOT PROVIDED" && uc($split1[9]) ne "NOT PROVIDED" && $split1[8] ne "no assertion criteria provided" && $split1[8] ne "no assertion provided"){
    my $temp2="$split1[7]|$split1[9]";
    $submitter{$split1[5]}=$split1[6];
    $pos{$split1[5]}=$temp1;
    if (exists $var{$split1[5]}){
     my @split2=split /\|\|/,$var{$split1[5]};
     my $iden=0;
     foreach my $split2 (@split2){
      if ($split2 eq $temp2){
       $iden=1;
      }
     }
     if ($iden==0){
      $var{$split1[5]}="$var{$split1[5]}||$temp2";
     }
    }
    else{
     $var{$split1[5]}=$temp2;
    }
   }
  }
  close file1;
  print "Parsed year $i month $cyc ClinVar SCV\n";
 }
}

open out1, ">./ClinVar_curations_ClinGen_variants.txt";
foreach my $var (keys %var){
 print out1 "$var\t$pos{$var}\t$submitter{$var}\t$var{$var}\n";
}
close out1;

exit 0;
