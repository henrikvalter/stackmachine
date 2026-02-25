; should print 1
    ipush 4
    ipush 4
    branch_if_equal TRUE
FALSE:
    ipush 0
    iprint
    branch EXIT
TRUE:
    ipush 1
    iprint
EXIT:
    exit
