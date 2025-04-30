#!/usr/bin/perl -w
use strict;
use Getopt::Std;
my %opts;
getopt ('n:',\%opts);
my $name=$opts{'n'};

open file1, "gunzip -c ./ClinVarFullRelease/ClinVarFullRelease_$name.xml.gz |";
open out1, ">./by_SCV/ClinVar_by_SCV_$name.txt";
while (<file1>){
 chomp;
 if ($_=~/\<ClinVarSet/){
  my $rcv="";
  my $chr=""; my $pos=""; my $ref=""; my $alt="";
  my (%submitter,%lasteval,%revstat,%class);
  while (<file1>){
   chomp;
   if ($_=~/Type=\"RCV\"/){
    my @split9=split /Acc=\"RCV/,$_;
    if ($split9[1]){
     my @split10=split /\"/,$split9[1];
     $rcv="RCV$split10[0]";
    }
   }

   if ($_=~/Assembly=\"GRCh37\"/ && $_=~/AlleleVCF/){
    my @split1=split /Chr=\"/,$_;
    my @split2=split /positionVCF=\"/,$_;
    my @split3=split /referenceAlleleVCF=\"/,$_;
    my @split4=split /alternateAlleleVCF=\"/,$_;
    if ($split1[1] && $split2[1] && $split3[1] && $split4[1]){
     my @split5=split /\"/,$split1[1]; my @split6=split /\"/,$split2[1];
     my @split7=split /\"/,$split3[1]; my @split8=split /\"/,$split4[1];
     $chr=$split5[0]; $pos=$split6[0]; $ref=$split7[0]; $alt=$split8[0];
    }
   }

   if ($_=~/\<ClinVarAssertion/){
    my $scv=""; my $submitter=""; my $lasteval=""; my $revstat=""; my $class=""; my $desc=0;
    while (<file1>){
     chomp;
     if ($_=~/Acc=\"SCV/){
      my @split11=split /Acc=\"SCV/,$_;
      if ($split11[1]){
       my @split12=split /\"/,$split11[1];
       $scv="SCV$split12[0]";
      }
     }

     if ($_=~/submitter=\"/){
      my @split13=split /submitter=\"/,$_;
      if ($split13[1]){
       my @split14=split /\"/,$split13[1];
       $submitter=$split14[0];
      }
     }

     if ($_=~/DateLastEvaluated=\"/){
      my @split15=split /DateLastEvaluated=\"/,$_;
      if ($split15[1]){
       my @split16=split /\"/,$split15[1];
       $lasteval=$split16[0];
      }
     }

     if ($_=~/\<ReviewStatus/){
      my @split17=split /\<ReviewStatus/,$_;
      if ($split17[1]){
       my @split21=split /\>/,$split17[1];
       if ($split21[1]){
        my @split18=split /\<\/ReviewStatus/,$split21[1];
        $revstat=$split18[0];
       }
      }
     }

     if ($_=~/\<Description/){
      my @split19=split /\<Description/,$_;
      if ($split19[1]){
       my @split22=split /\>/,$split19[1];
       if ($split22[1]){
        my @split20=split /\<\/Description/,$split22[1];
        if ($desc==0){
         $class=$split20[0]; $desc=1;
        }
       }
      }
     }

     if ($_=~/\<\/ClinVarAssertion/){
      if ($scv ne ""){
       if ($lasteval eq ""){
        $lasteval="Not provided";
       }
       $submitter{$scv}=$submitter; $lasteval{$scv}=$lasteval;
       $revstat{$scv}=$revstat; $class{$scv}=$class;
      }
      last;
     }
    }
   }

   if ($_=~/\<\/ClinVarSet/){
    if ($chr ne ""){
     my @keys=keys %submitter;
     @keys=sort @keys;
     foreach my $keys (@keys){
      print out1 "$rcv\t$chr\t$pos\t$ref\t$alt\t$keys\t$submitter{$keys}\t$lasteval{$keys}\t$revstat{$keys}\t$class{$keys}\n";
     }
    }
    last;
   }
  }
 }
}
close file1;
close out1;
system ("bgzip -f ./by_SCV/ClinVar_by_SCV_$name.txt");

exit 0;
