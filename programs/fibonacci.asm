        ipush 1
        dup
        iprint
        istore 0    ;       mem[0] = a = 1
        ipush 1
        dup
        iprint
        istore 1    ;       mem[1] = b = 1
LOOP:   iload 0     ; a
        iload 1     ; a b
        dup         ; a b b
        istore 0    ; a b   mem[0] = b
        iadd        ; (a+b)
        dup         ; (a+b) (a+b)
        iprint      ; (a+b)
        istore 1    ;       mem[1] = (a+b)
        branch LOOP ;