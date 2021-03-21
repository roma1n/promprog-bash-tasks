BEGIN {
    # comand to print each word from new line
    cmd = "cat " input " | grep -Eo \"\\b[A-Za-z0-9]+\\b\""
    while ((cmd | getline word) > 0) {
        # calculate md5 hash
        hash_cmd = "echo \"" word "\" | md5sum"
        hash_cmd | getline hash
        close(hash_cmd)
        split(hash, a, " ")
        hash = a[1]

        hash_to_nums_cmd = "printf " hash " | od -A n -t d1"
        hash_to_nums_cmd | getline nums_str
        close(hash_to_nums_cmd)
        len = split(nums_str, nums_str_splitted, " ")
        num = 0
        for (i = 1; i <= len; ++i) {
            num *= 239
            num += int(nums_str_splitted[i])
        }
        # num is pretty random but same for same words

        reducer_num = num % workers
        print word "\t" 1 > "reducer" reducer_num
    }
    close(cmd)
}