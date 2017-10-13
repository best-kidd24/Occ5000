#!/bin/sh
ROOT_DIR=/mnt/data1/kidd/deeplab-v2
CAFFE_DIR=../deeplab-public-ver2
CAFFE_BIN=${CAFFE_DIR}/.build_release/tools/caffe.bin
EXP=voc12
	if [ "${EXP}" = "voc12" ]; then
		NUM_LABELS=21
		DATA_ROOT=${ROOT_DIR}/data/pascal/VOCdevkit/VOC2012/VOCtrainval
	else
		NUM_LABELS=0
	echo "Wrong exp name"
fi
NET_ID=deeplab_largeFOV
EXP=voc12
NET_ID=deeplab_largeFOV
CONFIG_DIR=${EXP}/config/${NET_ID}
TEST_SET=val
sed "$(eval echo $(cat sub.sed))" \
                         ${CONFIG_DIR}/test.prototxt > ${CONFIG_DIR}/test_${TEST_SET}.prototxt

