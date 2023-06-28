#!/usr/bin/env bash
# encoding: utf-8.0

set -o errexit

splitByRow=${SPLIT_BY_ROW:-10}
fileNameSuffixPadding=${FILE_NAME_SUFFIX_PADDING:-4}
PROCESS_UUID=$(uuidgen |sed 's/-//g')

splittedFiles=()
convertXlsxs=()

function split_csv {
    local origin_file_name=$1
    rm -fr data/process/${PROCESS_UUID} && mkdir data/process/${PROCESS_UUID}
    # 这样是把test.csv文件按10行拆分文件，-d是增加数字后缀，-a是指定数字后缀的长度，这里设置成4位，不满4位前面补0，--additional-suffix是增加后缀，data_是文件前缀；
    # split -l 10 test.csv -d -a 4 --additional-suffix=.csv data_
    split -l ${splitByRow} ${origin_file_name} -d -a ${fileNameSuffixPadding} --additional-suffix=.csv data/process/${PROCESS_UUID}/data_

    # record splitted files to the array: splittedFiles
    while IFS=  read -r -d $'\0'; do
        splittedFiles+=("$REPLY")
    done < <(find data/process/${PROCESS_UUID} -type f -print0)

    # csv_convert_xlsx
}


# csv 2 xlsx
#csv2xlsx -i test.csv -o test.xlsx
function csv_convert_xlsx {
    for file in "${splittedFiles[@]}"; do
        #echo "$file"
        local filePrefixName=${file%.*}
        #echo "文件名: ${filePrefixName}"
        #echo "扩展名：${i#*.}"
        #echo "csv2xlsx -i $file -o ${filePrefixName}.xlsx"
        csv2xlsx -i $file -o ${filePrefixName}.xlsx
        convertXlsxs+=(${filePrefixName}.xlsx)
    done
}

# watermarker
#java -jar ./watermarker-cmd-1.0.jar --watermark=中文测试 --inputFileFullPath=/lyndon/iProject/shellpath/csv-xlsx-watermarker/data/receive/test.xlsx --outputFileFullPath=/lyndon/iProject/shellpath/csv-xlsx-watermarker/data/done/test-watered.xlsx
function watermark_xlsx {
    local wmark=$1
    rm -fr data/done/${PROCESS_UUID} && mkdir data/done/${PROCESS_UUID}
    #echo "wmark:${wmark}"
    for xfile in "${convertXlsxs[@]}"; do
        #echo "xfile: ${xfile}"
        local xFilePrefixName=${xfile}
        local targetFileName=${xFilePrefixName##*/}
        #echo "targetFileName: ${targetFileName}"
        #echo "java -jar ./watermarker-cmd-1.0.jar --watermark=${wmark} --inputFileFullPath=${xfile} --outputFileFullPath=data/done/${PROCESS_UUID}/${targetFileName}"
        java -jar ./watermarker-cmd-1.0.jar --watermark=${wmark} --inputFileFullPath=${xfile} --outputFileFullPath=data/done/${PROCESS_UUID}/${targetFileName}
    done
    rm -fr data/process/${PROCESS_UUID}
}

# tar.gz
function tar_and_gz {
    rm -f data/done/${PROCESS_UUID}.tar.gz

    tar -zcvf data/done/${PROCESS_UUID}.tar.gz data/done/${PROCESS_UUID}
    rm -fr data/done/${PROCESS_UUID}
}

# mv to backup
function to_backup {
    rm -f data/backup/${PROCESS_UUID}.tar.gz
    mv data/done/${PROCESS_UUID}.tar.gz data/backup/
}


function main {
    local origin_file_name=$1
    local water_mark=$2
    split_csv ${origin_file_name}
    csv_convert_xlsx
    watermark_xlsx ${water_mark}
    tar_and_gz
    to_backup
}


$@
