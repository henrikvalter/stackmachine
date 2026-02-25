    ipush 0                     ; 0
LOOP:
    dup                         ; i i
    iprint                      ; i
    ipush 1                     ; i 1
    iadd                        ; i (incremented)
    dup                         ; i i
    ipush 100                   ; i 100
    branch_if_not_equal LOOP    ;
    exit
