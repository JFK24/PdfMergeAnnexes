#!/bin/bash
#
# Bash version of PdfMergeAnnexes
#
# This script will merge all input files in a single PDF. One file is considered
# the main PDF document and other files annexes or supplementary content. The
# latter will be automatically converted in PDF before merging. Few or no
# options are provided for the conversion, thus manual conversion could be a
# better option.

# Input:
# 1. Path to main PDF file (typically a scientific article)
# 2. comma-separated list of annexes files paths (images, text or pdf files).

# Output:

# A new PDF file in the working directory including the content of all input
# files. First the main document, then each file from the list preceeded by a
# cover page mentioning the file name.

# Author: JFK24
# Date: 2018-09-17

# Dependencies
# * pdftk
# * enscript
# The ~/.enscriptrc file must include the following line:
# Media:	A0		2380	3356	18	17	2366	3339

###############################################################################
# GET PARAMETERS
###############################################################################
HELP=0

POSITIONAL=()
while [[ $# -gt 0 ]]
do
    key="$1"

    case $key in
	-m|--main)
	    MAINPDF="$2"
	    shift # past argument
	    shift # past value
	    ;;
	-a|--annexes)
	    ANNEXES_LIST="$2"
	    shift # past argument
	    shift # past value
	    ;;
	-h|--help)
	    HELP=1
	    shift # past argument
	    ;;
	*)    # unknown option
	    POSITIONAL+=("$1") # save it in an array for later
	    shift # past argument
	    ;;
    esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

if [ $HELP = 1 ]; then
   echo "Usage: ./PdfMergeAnnexes.sh -m mainDocument.pdf -a annexe1.pdf,annexe2.jpg,annexe2.tsv,annexe2.txt"
   exit 0
fi

# Convert comma-separated list into an array
IFS=',' read -ra ANNEXES_ARRAY <<< "$ANNEXES_LIST"
if [ ${#ANNEXES_ARRAY[@]} = 0 ]; then
   echo "Array size = 0"
   exit 0
fi

###############################################################################
# CONTROL
###############################################################################
echo MAIN PDF = "${MAINPDF}"
echo "ANNEXES"
printf "\t%s\n" "${ANNEXES_ARRAY[@]}"

###############################################################################
# CREATE COVER PAGE FOR EACH ANNEX
###############################################################################

echo "1. Creating cover pages ..."
for i in "${ANNEXES_ARRAY[@]}"; do
	iname=$(basename "$i")
	echo "Supplementary file:" > $i.cover.txt
	echo "" >> $i.cover.txt
	echo "$iname" >> $i.cover.txt
	if [ ! -f $i.cover.pdf ]; then
		echo -e "\tiname"
    	enscript $i.cover.txt --no-header -o - | ps2pdf - $i.cover.pdf
	fi
done

###############################################################################
# CONVERTING ANNEXES TO PDF
###############################################################################

echo "2. Converting files ..."
for i in "${ANNEXES_ARRAY[@]}"; do
	iname=$(basename "$i")
	iext="${iname##*.}"
	case $iext in
    	png|jpg|tif)
			if [ ! -f $i.out.pdf ]; then
				echo -e "\t$iname -- $iext"
				convert $i $i.out.pdf
			fi
        	;;
    	tsv|csv)
			if [ ! -f $i.out.pdf ]; then
				echo -e "\t$iname -- $iext"
				enscript $i --no-header --mark-wrapped-lines=plus --line-numbers=1 --media=A0 --landscape --font=Courier7 -o - | ps2pdf - $i.out.pdf
			fi
        	;;
    	R|r|txt)
			if [ ! -f $i.out.pdf ]; then
				echo -e "\t$iname -- $iext"
				enscript $i --no-header  --media=A3 --landscape --font=Courier7 -o - | ps2pdf - $i.out.pdf
			fi
        	;;
    	pdf)
			if [ ! -f $i.out.pdf ]; then
				echo -e "\t$iname -- $iext"
				cp $i $i.out.pdf
			fi
        	;;
    	*)
	        echo "Unsupported format"
	esac
done


###############################################################################
# MERGING FILES
###############################################################################

echo "3. Merging files ..."
ORDERED_FILES_LIST="$MAINPDF "
for i in "${ANNEXES_ARRAY[@]}"; do
	ORDERED_FILES_LIST+=" $i.cover.pdf $i.out.pdf"
done

fname=$(basename "$MAINPDF" .pdf)
dpath=$(dirname "$MAINPDF") 

pdftk $ORDERED_FILES_LIST cat output $dpath/$fname.merged.pdf


###############################################################################
# CLEANING
###############################################################################
for i in "${ANNEXES_ARRAY[@]}"; do
	rm $i.cover.txt
	rm $i.cover.pdf
	rm $i.out.pdf
done

