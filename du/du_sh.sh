#!/bin/bash

awk -v root=$1 'BEGIN {
	sum = 0
	dirs[0] = root
	begin = 0
	end = 1
	while(begin < end) {
		dirname = dirs[begin]
		cmd = "ls -la \"" dirname "\""
		first_skipped = 0
		while ( ( cmd | getline result ) > 0 ) {
			if (first_skipped == 0) {
				first_skipped = 1
				continue
			}
			len = split(result, a, " ")
			sum += a[5]
			if (substr(a[1], 0, 1) == "d") { // is directory
				name = a[9]
				for (i = 10; i < len + 1; i++)
					name = name " " a[i]
				if (name != "." && name != "..") {
					dirs[end] = dirname "/" name
					end = end + 1
				}
			}
		}
		close(cmd)
		begin = begin + 1
	}
	print sum
}'
