; should print 3 forever
    ipush 3
START:
    dup
    iprint
    branch START
    exit
