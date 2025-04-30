#!/usr/bin/perl -w
use strict;

my %inlab;
open file1, "<./ClinVar_submitters_ClinGen_variants.txt";
while (<file1>){
 chomp;
 my @split1=split /\t/,$_;
 if ($split1[1]>=50){
  $inlab{$split1[0]}=1;
 }
}
close file1;

my %clingen;
open file1, "<./ClinGen_VCEP_curations_grouped.txt";
while (<file1>){
 chomp;
 my @split1=split /\t/,$_;
 my @split2=split /\|/,$split1[1];
 if ($split1[2] eq "Train"){
  $clingen{$split1[0]}=$split2[0];
 }
}
close file1;

my (%resu1,%resu2,%resu3,%tot1,%tot2,%tot3);
open file1, "<./ClinVar_curations_before_ClinGen.txt";
while (<file1>){
 chomp;
 my @split1=split /\t/,$_;
 if (exists $clingen{$split1[1]} && exists $inlab{$split1[2]}){
  $tot1{$split1[2]}++;
  if ($clingen{$split1[1]} eq $split1[4]){
   $resu1{$split1[2]}++;
  }
  if ($split1[4] eq "LP/P"){
   $tot2{$split1[2]}++;
   if ($clingen{$split1[1]} eq "LP/P"){
    $resu2{$split1[2]}++;
   }
  }
  else{
   $tot3{$split1[2]}++;
   if ($clingen{$split1[1]} ne "LP/P"){
    $resu3{$split1[2]}++;
   }
  }
 }
}
close file1;

open out1, ">./ClinVar_train_results.txt";
foreach my $keys (keys %tot1){
 my $rt1=sprintf("%.4f",$resu1{$keys}/$tot1{$keys});
 my $rt2="NA";
 if (!exists $tot2{$keys}){
  $tot2{$keys}="NA"; $resu2{$keys}="NA";
 }
 else{
  if (!exists $resu2{$keys}){
   $resu2{$keys}=0;
  }
  $rt2=sprintf("%.4f",$resu2{$keys}/$tot2{$keys}); #PPV
 }
 my $rt3="NA";
 if (!exists $tot3{$keys}){
  $tot3{$keys}="NA"; $resu3{$keys}="NA";
 }
 else{
  if (!exists $resu3{$keys}){
   $resu3{$keys}=0;
  }
  $rt3=sprintf("%.4f",$resu3{$keys}/$tot3{$keys}); #NPV
 }
 print out1 "$keys\t.\t.\t.\t$resu2{$keys}\t$tot2{$keys}\t$rt2\t$resu3{$keys}\t$tot3{$keys}\t$rt3\n";
}
close out1;

exit 0;
