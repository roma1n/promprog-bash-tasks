#!/bin/bash

STRATISFIED="NO"
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
        -tr|--train-ratio)
        TRAIN_RATIO="$2"
        shift # past argument
        shift # past value
        ;;
        -s|--stratisfied)
        STRATISFIED="YES"
        shift # past argument
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

awk -v input=$INPUT -v train_ratio=$TRAIN_RATIO -v stratisfied=$STRATISFIED -v column=$COLUMN 'BEGIN {
    srand()
    cmd = "cat " input
    # calculate amount of each class
    line_num = 0
    while ((cmd | getline result) > 0) {
        len = split(result, a, ",")

        # process header
        if (line_num == 0) {
            # determine column index
            column_index = -1
            for (i = 1; i <= len; ++i) {
                if (a[i] == column) {
                    column_index = i
                    if (column_index > 4) {
                        ++column_index
                    }
                    break
                }
            }
            ++line_num
            continue
        }

        # process data line
        val[line_num] = a[column_index]
        ++line_num
    }
    close(cmd)

    # create split mask
    if (stratisfied == "YES") {
        for (i = 0; i < line_num; ++i) { # init class bin sizes
            classes[val[i]] = 0
        }
        for (i = 0; i < line_num; ++i) { # calculate bin sizes
            ++classes[val[i]]
        }
        for (key in classes) {
            bin_size = classes[key]
            for (i = 0; i < bin_size; ++i) {
                if (i / bin_size <= train_ratio) {
                    bins[key, i] = 0
                } else {
                    bins[key, i] = 1
                }
            }
            # make permutation
            for (i = 0; i < bin_size; ++i) {
                j = int(rand() * bin_size) % bin_size
                tmp = bins[key, i]
                bins[key, i] = bins[key, j]
                bins[key, j] = tmp
            }
        }
    } else {
        bin_size = line_num
        for (i = 0; i < bin_size; ++i) {
            if (i / bin_size <= train_ratio) {
                bins[i] = 0
            } else {
                bins[i] = 1
            }
        }
        # make permutation
        for (i = 0; i < bin_size; ++i) {
            j = int(rand() * bin_size) % bin_size
            tmp = bins[i]
            bins[i] = bins[j]
            bins[j] = tmp
        }
    }

    system("touch train.csv")
    system("touch test.csv")

    # write outpyt files
    if (stratisfied == "YES") {
        for (key in classes) {
            bin_index[key] = 0
        }

        line_num = 0
        while ((cmd | getline result) > 0) {
            if (line_num == 0) {
                ++line_num
                continue
            }
            len = split(result, a, ",")
            key = a[column_index]
            if (bins[key, bin_index[key]] == 0) {
                # write to train
                print result > "train.csv"
            } else {
                #write to test
                print result > "test.csv"
            }
            ++bin_index[key]
            ++line_num
        }
        close(cmd)
    } else {
        bin_index[0] = 0
        line_num = 0
        while ((cmd | getline result) > 0) {
            if (line_num == 0) {
                ++line_num
                continue
            }

            len = split(result, a, ",")
            key = 0
            if (bins[bin_index[key]] == 0) {
                # write to train
                print result > "train.csv"
            } else {
                #write to test
                print result > "test.csv"
            }
            ++bin_index[key]
            ++line_num
        }
        close(cmd)
    }
}'
