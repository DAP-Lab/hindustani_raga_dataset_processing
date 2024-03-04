##
# This is the driver code for audio processing.
# Input - Directory containing source separated cropped audio (cropped based on start and stop times)
# Processing:-
#     The code does the following processing steps:-
#        1.  Extraction of pitch contours using parselmouth - normalized using tonic values
# OUTPUTS
#        1.  Extracted pitch contour
#
#

TARGET_DIR="../03_audio_processing_data"
SPLIT_AUDIO_DIRECTORY=${TARGET_DIR}/"01_source_separated_audio"
PITCH_CONTOUR_DIRECTORY=${TARGET_DIR}/"02_pitch_contour_dir"
USE_SINGER_SPECIFIC_TONICS="Y"
USE_PARSELMOUTH_ALL="Y"
NORMALIZE_PITCH_CONTOURS="Y"

for each_dir in `ls -l $SPLIT_AUDIO_DIRECTORY | grep ^d | awk '{print $9}'`
do
    mv ${SPLIT_AUDIO_DIRECTORY}/${each_dir}/* ${SPLIT_AUDIO_DIRECTORY}
done

if [[ $USE_SINGER_SPECIFIC_TONICS == "Y" ]]
then
    TONIC_FOLDER="../00_data/03_singer_specific_tonic"
    for each_file in `ls ${SPLIT_AUDIO_DIRECTORY}`
    do
        echo "Running for $each_file"
        inputfile=${SPLIT_AUDIO_DIRECTORY}/$each_file
        singer_name=`basename $each_file | awk -F"_" '{print $1}'`
        echo "Singer is ${singer_name}"
        tonic_file_name=${singer_name}_tonic.txt
        tonicfilename_full_path=$TONIC_FOLDER/$tonic_file_name
        if [[ $NORMALIZE_PITCH_CONTOURS == "Y" ]]
        then
            python extract_pitch_contours.py $inputfile  $tonicfilename_full_path ${PITCH_CONTOUR_DIRECTORY}
        else
            python extract_pitch_contours.py $inputfile  ${PITCH_CONTOUR_DIRECTORY}
        fi
    done
fi

