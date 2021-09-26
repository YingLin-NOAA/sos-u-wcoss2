#!/bin/bash

# samples:
#	ll /gpfs/dell1/nco/ops/dcom/prod/20210512/wgrbbul/cmcens_gb2/2021051212*|wc -l
#	ll /gpfs/dell1/nco/ops/dcom/prod/20210511/wgrbbul/cmcens_gb2/2021051112*|wc -l

if [ ! $# -eq 4 ]
then
	echo "Usage $0 <Yesterday PDY> <Today PDY> <cycle> <your email address>"
	echo "Example: $0 20210511 20210512 12 Hoai.Vo@noaa.gov"
	exit 1
fi

yesterday=${1}
today=${2}
cycle=${3}
email_addr=${4}
missing=/u/Hoai.Vo/cmc/missing.txt

rm -rf ${missing}
touch ${missing}

yesterday_dir="/gpfs/dell1/nco/ops/dcom/prod/${yesterday}/wgrbbul/cmcens_gb2"
cd ${yesterday_dir}
yesterday_file_count=`ls -1 ${yesterday}${cycle}* | wc -l`
yesterday_files="ls -1 ${yesterday}${cycle}*"

today_dir="/gpfs/dell1/nco/ops/dcom/prod/${today}/wgrbbul/cmcens_gb2"
today_file_count=0

for FILE in `eval ${yesterday_files}`
do
	LEN=${#FILE}
	PART=$(echo ${FILE} | cut -c11-${LEN})
	NEW_FILE=${today}${cycle}${PART}

	cd ${today_dir}
	ls ${NEW_FILE}
	if [ $? -ne 0 ]
	then
		echo "${NEW_FILE}" >> ${missing}
	else
		today_file_count=$((today_file_count+1))
	fi
done
diff_file_count=$((yesterday_file_count-today_file_count))
if [ -s ${missing} ]
then
	echo "${yesterday}'s CMC file count: ${yesterday_file_count}" >> ${missing}
	echo "${today}'s CMC file count: ${today_file_count}" >> ${missing}
	echo "Diff CMC file count: ${diff_file_count}" >> ${missing}
	cat ${missing} | mail -s "missing cmc files" ${email_addr}
fi
