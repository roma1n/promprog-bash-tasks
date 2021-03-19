#!/bin/bash

POSITIONAL=()

while [[ $# -gt 0 ]]
    do
    key="$1"

    case $key in
        -i|--input)
        INPUT="$2"
        shift # past argument
        shift # past value
        ;;
        -w|--workers)
        WORKERS="$2"
        shift # past argument
        shift # past value
        ;;
        -d|--directory)
        DIRECTORY="$2"
        shift # past argument
        shift # past value
        ;;
        -c|--column)
        COLUMN="$2"
        shift # past argument
        shift # past value
        ;;
        *)    # unknown option
        POSITIONAL+=("$1") # save it in an array for later
        shift # past argument
        ;;
    esac
done

awk -v column=$COLUMN -v input=$INPUT 'BEGIN {
    line_num = 0
    cmd = "cat " input
    while ((cmd | getline result) > 0) {
        len = split(result, a, "\t")

        # process header
        if (line_num == 0) {
            # determine column index
            column_index = -1
            for (i = 1; i <= len; ++i) {
                if (a[i] == column) {
                    column_index = i
                    break
                }
            }
            ++line_num
            continue
        }

        # process data line
        val = a[column_index]
        print val
        ++line_num
    }
    close(cmd)
}' | parallel -j $WORKERS wget -q -P $DIRECTORY {}
