# Leveraging ClinVar for Accurate and Automated Germline Variant Interpretation
<br>This repository contains scripts used for ClinVar data extraction and for training and testing a binary germline variant classification tool. The classifier is designed to predict variant pathogenicity by leveraging submissions from high-concordance ClinVar submitters.<br><br>
<b>Citation:</b> to be added.<br>
<b>Contact:</b> ding.qiliang@mayo.edu<br><br>
<h2>Instructions</h2>
<b>Step 1: Set Up Your Working Directory</b><br>

Create a new working folder, e.g., `mkdir classifier_project`, and place all classifier scripts from this GitHub repository into this directory. Inside this folder, create three subdirectories: `mkdir ClinVarFullRelease by_SCV results`<br>

<b>Step 2: Download ClinVar XML Files</b><br>
Download the monthly ClinVar full release XML files from January 2018 to December 2024 from https://ftp.ncbi.nlm.nih.gov/pub/clinvar/xml/RCV_xml_old_format/ and https://ftp.ncbi.nlm.nih.gov/pub/clinvar/xml/RCV_xml_old_format/archive/ (for older releases).<br>
Place all downloaded `ClinVarFullRelease_YYYY-MM.xml.gz` files into the `ClinVarFullRelease/` subdirectory.

<b>Step 3: Extract ClinVar Data</b><br>
Run the extraction script for each monthly file:`perl ClinVar_extract.pl -n YYYY-MM`. Repeat for each month from 2018-01 to 2024-12.

<b>Step 4: Train the Classifier</b><br>
Execute the training script: `perl classifier_train1.pl`. This will generate `./results/train_results.$thres.txt` files ($thres from 0.800 to 0.950, with 0.025 increments. To choose the optimal threshold, examine columns 3 (total number of classifiable variants), 6 (PPV), and 9 (NPV). The threshold value is in column 1.

<b>Step 5: Test the Classifier</b><br>
Once you’ve selected an appropriate threshold (e.g., 0.825), test the classifier: `perl classifier_test.pl -t [selected threshold]`. Check the `classifier_test_results.txt` file. The test performance (e.g., % classifiable, PPV, and NPV) should be comparable to the training results.

<b>Step 6: Run Classification on All Variants</b><br>
To classify variants using the trained model: `perl classification.pl -t [selected threshold]`. The results will be saved to: `./classification_results.txt`. This file contains the final binary classification output for each variant (LP/P or non-LP/P).
