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
        -c|--category_id)
        CATEGORY="$2"
        shift # past argument
        shift # past value
        ;;
        *)    # unknown option
        POSITIONAL+=("$1") # save it in an array for later
        shift # past argument
        ;;
    esac
done

jq --arg v "$CATEGORY" '(.annotations[] | select(.category_id == ($v|tonumber) )) as $annot | .images[] | select(.id == $annot.image_id)' $INPUT
