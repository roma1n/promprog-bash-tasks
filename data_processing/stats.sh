#!/bin/bash

awk -v stat=$1 -v input=$2 'BEGIN {
	print "Stat: " stat
    print "Input: " input
    if (input == "") {
        input = "titanic.csv"
    }
	cmd = "cat " input
	line_num = 0
	n_bins = 10
	if (stat == "survived")
		n_bins = 2
	if (stat == "pclass")
		n_bins = 3
	if (stat == "embarked")
		n_bins = 3
	max_bin_len = 50
	min = 0
	max = 0
	# read column, count min and max
	while ((cmd | getline result) > 0) {
		if (line_num == 0) {
			line_num++
			continue
		}
		split(result, a, ",")
		if (stat == "survived")
			val = a[2]
		if (stat == "pclass")
			val = a[3]
		if (stat == "age")
			val = a[7]
		if (stat == "embarked") {
			emb = substr(a[13], 0, 1)
			if (emb == "C")
				val = 0
			if (emb == "S")
				val = 1
			if (emb == "Q")
				val = 3
		}
		vals[line_num] = val
		if (line_num == 1) {
			min = val
			max = val
		} else {
			if (val < min)
				min = val
			if (val > max)
				max = val
		}
		line_num++
	}

	# difine bins
	len_seg = (max - min) / n_bins
	lower = min
	for (i = 0; i < n_bins; i++)
		bins[i] = 0

	# count bins
	for (i = 0; i < n_bins; i++) {
		for (j = 1; j < line_num; j++) {
			if (vals[j] >= lower) {
				bins[i]++
			}
		}
		lower += len_seg
		if (i > 0) {
			bins[i - 1] = bins[i - 1] - bins[i]
		}
	}

	# plot hist
	max_bin = bins[0]
	for (i = 1; i < n_bins; i++) {
		if (bins[i] > max_bin) {
			max_bin = bins[i]
		}
	}
	for (i = 0; i < n_bins; i++) {
		plot_bins[i] = int(bins[i] * max_bin_len / max_bin)
	}
	print "bin #\tlower\tupper\t size"
	for (i = 0; i < n_bins; i++) {
		line = i + 1 "\t" min + i * len_seg
		line = line "\t" min + (i + 1) * len_seg  "\t"
		for (tmp = 0; tmp < plot_bins[i]; ++tmp)
			line = line "#"
		print line
	}
}'
