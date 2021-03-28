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
        -s|--size)
        SIZE="$2"
        shift # past argument
        shift # past value
        ;;
        *)    # unknown option
        POSITIONAL+=("$1") # save it in an array for later
        shift # past argument
        ;;
    esac
done

jq --arg v "$SIZE" '.images[] | select(.width > ($v|tonumber) and .height > ($v|tonumber))' $INPUT
