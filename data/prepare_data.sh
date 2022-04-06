#!/bin/bash

set -e

# check argument
if [[ -z $1 || ! $1 =~ [[:digit:]]x[[:digit:]] ]]; then
  echo "ERROR: This script requires 1 argument, \"input dimension\" of the YOLO model."
  echo "The input dimension should be {width}x{height} such as 608x608 or 416x256.".
  exit 1
fi

if which python3 > /dev/null; then
  PYTHON=python3
else
  PYTHON=python
fi

echo "** Install requirements"
# "gdown" is for downloading files from GoogleDrive
pip3 install --user gdown > /dev/null

# make sure to download dataset files to "yolov4_crowdhuman/data/raw/"
mkdir -p $(dirname $0)/raw
pushd $(dirname $0)/raw > /dev/null

get_file()
{
  # do download only if the file does not exist
  if [[ -f $2 ]];  then
    echo Skipping $2
  else
    echo Downloading $2...
    python3 -m gdown.cli $1
  fi
}

echo "** Download dataset files"
get_file https://drive.google.com/uc?id=1sHTitzBm8worH65vEcBk0C8C-rdpbjK5&confirm=t #CrowdHuman_train01.zip
get_file https://drive.google.com/uc?id=1P5u9yh7WOYLR8BZ1WyCiFt86a0M_XTy5&confirm=t #CrowdHuman_train02.zip
get_file https://drive.google.com/uc?id=1BZtyes22dI8wQSmrVhohv-APbvhPkB88&confirm=t #CrowdHuman_train03.zip
get_file https://drive.google.com/uc?id=1p3jDRhKnFjc8VB2odDPLeH-9ccVaQSzr&confirm=t #CrowdHuman_val.zip
# test data is not needed...
# get_file https://drive.google.com/uc?id=1tQG3E_RrRI4wIGskorLTmDiWHH2okVvk CrowdHuman_test.zip
get_file https://drive.google.com/uc?id=14njhG0-mOVcvtIH6Dq1vBtd10vVViCZ-&confirm=t #annotation_train.odgt
get_file https://drive.google.com/uc?id=1Gj30JcW9Nwvl3W8IOLD-fV_jzwhfcqxe&confirm=t #annotation_val.odgt

# unzip image files (ignore CrowdHuman_test.zip for now)
echo "** Unzip dataset files"
for f in CrowdHuman_train01.zip CrowdHuman_train02.zip CrowdHuman_train03.zip CrowdHuman_val.zip ; do
  unzip -n ${f}
done

echo "** Create the crowdhuman-$1/ subdirectory"
rm -rf ../crowdhuman-$1/
mkdir ../crowdhuman-$1/
ln Images/*.jpg ../crowdhuman-$1/

# the crowdhuman/ subdirectory now contains all train/val jpg images

echo "** Generate yolo txt files"
cd ..
${PYTHON} gen_txts.py $1

popd > /dev/null

echo "** Done."
