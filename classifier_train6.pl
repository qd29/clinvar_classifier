#!/usr/bin/perl -w
use strict;
use Getopt::Std;
my %opts;
getopt ('t:',\%opts);
my $thres=$opts{'t'};

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

open file1, "<./ClinVar_curations_before_ClinGen.txt";
my (%var,%varp,%varb);
while (<file1>){
 chomp;
 my @split1=split /\t/,$_;
 my $temp1=$split1[1];
 if (exists $subp{$split1[2]} && exists $subb{$split1[2]}){
  $var{$temp1}=1;
  if (exists $varp{$temp1}){
   $varp{$temp1}="$varp{$temp1}|$split1[4]";
  }
  else{
   $varp{$temp1}=$split1[4];
  }
 }
}
close file1;

open out1, ">./results/variants.$thres.txt";
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

exit 0;
