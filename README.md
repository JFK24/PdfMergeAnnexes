# PdfMergeAnnexes (Beta!)
Merges a main PDF document with its annexes (this is a beta version with many limitations). 

This script will merge all input files in a single PDF. One file is considered the main PDF document and other files annexes or supplementary content. The latter will be automatically converted in PDF before merging. Few or no options are provided for the conversion, thus manual conversion could be a better option. 

## Input:
1. A main PDF file
2. list of image, text or pdf files (png, jpg, tif, tsv, csv, r, txt, and pdf files)

## Output:

* A new PDF file in the directory of the main PDF file including the content of all input files: first the main document, then each file from the list preceeded by a cover page mentioning the file name. 

## Dependencies

The following packages must be installed:

* imagemagick (especially the convert program)
* pdftk
* enscript

A custom enscript media "A0" must be configured for tsv/csv annexes support. It can be done by adding the following line in your ~/.enscriptrc file:

Media:	A0		2380	3356	18	17	2366	3339

## Usage

./PdfMergeAnnexes.sh -m path_to_mainDocument.pdf -a path_to_annexe1.pdf,path_to_annexe2.jpg,path_to_annexe2.tsv,path_to_annexe2.txt
