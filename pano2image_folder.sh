#! /bin/bash
####
# Splits a panorama image into "block" views (up, down, left, front, right, back) virtual cameras
####
# immediately exit upon error
set -e
# error upon unset variables
set -u

INPUT_FOLDER="$1"
OUTPUT_FOLDER="$2"
WIDTH="$3" # e.g. 1000
PROCESSES_IN_PARALLEL=$4 # e.g. 16

# TODO(nik): Is it possible to get away without this function?
convert_one_pano2image(){
   FILE=$1
   OUTPUT_FOLDER=$2
   WIDTH=$3
   echo "convert360 --convert pano2images -i \"$1\" -o \"$OUTPUT_FOLDER/${FILE##*/}\" --output_width $WIDTH" >&2
   convert360 --convert pano2images -i "$1" -o "$OUTPUT_FOLDER/${FILE##*/}" --output_width $WIDTH
}
export -f convert_one_pano2image
parallel -j $PROCESSES_IN_PARALLEL 'convert_one_pano2image {1} {2} {3}' ::: $INPUT_FOLDER/*.jpg ::: $OUTPUT_FOLDER ::: $WIDTH

echo "pano2image conversion done"
