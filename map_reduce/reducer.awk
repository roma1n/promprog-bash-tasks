BEGIN{
    cmd = "cat " input
    while ((cmd | getline line) > 0) {
        split(line, a, "\t")
        word = a[1]
        count = a[2]
        if (word in result) {
            result[word] += count
        } else {
            result[word] = count
        }
    }
    close(cmd)
    for (word in result)
        print word "\t" result[word]
}