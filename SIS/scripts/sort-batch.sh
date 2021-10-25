#!/bin/bash

# A bash script to sort formats of multiple recommendation files.
#
# For each file, the format names will be sorted by domain names
# alphabetically. Moreover, for each domain, the formats are then
# sorted by their id alphabetically.
#
# The sorted recommendation files will be created in the given output
# directory.
#
# Requirements
#   * java
#   * a saxon library
#   * an input directory of recommendation files
#   * sort-format.xq
#
#  How to run the programm
#
#   ./sort-batch.sh [input directory] [saxon jar] [output directory]
#
#  Example
#
#  ./sort-batch.sh recommendations saxon-he-10.6.jar output
#
# Author: Eliza Margaretha
# Date: Oct 14th, 2021



printHelp(){
  echo "Please use the following command:"
  echo "  ./sort-batch.sh [input directory] [saxon jar] [output directory]"
}


runXQ(){
  echo 'Sorting' $1
  filename=$3/"$(basename $1)"
  java -cp $2 net.sf.saxon.Query -s:$1 sort-format.xq > $filename
}

export -f runXQ

inputDir=$1
saxonJar=$2
outputDir=$3

if [ -z $1 ]||[ -z $2 ]||[ -z $3 ] ;
then
    printHelp
    exit
fi

mkdir -p $outputDir

find $inputDir -type f -exec bash -c 'runXQ "$0" "$1" "$2"' {} $saxonJar $outputDir \;

echo 'Done. Sorted files can be found in' $3
