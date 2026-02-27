    ipush 2             ; x = 2
LOOP:
    dup                 ; x x
    iprint              ; x
    dup                 ; x x
    iadd                ; 2x
    dup                 ; 2x 2x
    ipush 2048          ; 2x 2x 2048
    branch_if_equal END ; 2x,   if 2x == 2048, jump to END,
    branch LOOP         ; else, repeat the loop
END:
    iprint              ; print 2048
    exit                ; end the program