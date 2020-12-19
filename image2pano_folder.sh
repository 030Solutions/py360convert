#! /bin/bash
####
# takes "block" views (up, down, left, front, right, back) of a virtual camera and transforms it back to panorama images
####
# immediately exit upon error
set -e
# error upon unset variables
set -u

INPUT_FOLDER="$1"
OUTPUT_FOLDER="$2"
PROCESSES_IN_PARALLEL=$3 # e.g. 16
OUTPUT_WIDTH=$4 # 8000 for trimble data
OUTPUT_HEIGHT=$5 # 4000 for trimble data

convert_one_image2pano(){
    FILE=$1
    OUTPUT_FOLDER=$2
    OUTPUT_WIDTH=$3
    OUTPUT_HEIGHT=$4
    OUTFILE=${FILE##*/} # remove path and keep filename
    OUTFILE=$(echo $OUTFILE | sed -e "s/_left//" )
    echo "convert360 --convert images2pano -i \"$FILE\" -o \"$OUTPUT_FOLDER/$OUTFILE\" --output_width $OUTPUT_WIDTH --output_height $OUTPUT_HEIGHT --mode nearest"  >&2
    convert360 --convert images2pano -i "$FILE" -o "$OUTPUT_FOLDER/$OUTFILE" --output_width $OUTPUT_WIDTH --output_height $OUTPUT_HEIGHT --mode nearest
    echo "" >&2
}
export -f convert_one_image2pano
parallel -j $PROCESSES_IN_PARALLEL 'convert_one_image2pano {1} {2} {3} {4}' ::: $INPUT_FOLDER/*_left*.png ::: $OUTPUT_FOLDER ::: $OUTPUT_WIDTH ::: $OUTPUT_HEIGHT

echo "image2pano conversion done"
