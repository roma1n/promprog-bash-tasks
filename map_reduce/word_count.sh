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
        *)    # unknown option
        POSITIONAL+=("$1") # save it in an array for later
        shift # past argument
        ;;
    esac
done

# Mapper
awk -v input=$INPUT -v workers=$WORKERS -f mapper.awk

# Reducers
awk -v workers=$WORKERS 'BEGIN{
    for (i = 0; i < workers; ++i)
        print "reducer" i
}' | parallel -j $WORKERS awk -v input={} -f reducer.awk
