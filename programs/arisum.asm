

        ipush 1
loop:
        dup             ; n n
        call arisum     ; n arisum(n)
        iprint          ; n
        dup             ; n n
        ipush 20        ; n n 20
        branch_if_equal done ; n
        ipush 1         ; n 1
        iadd            ; n+1
        branch loop
done:
        exit

arisum: dup                     ; n n
        ipush 1                 ; n n 1
        branch_if_equal ret     ; n (=1)
        dup                     ; n n
        ipush 1                 ; n n 1
        isub                    ; n (n-1)
        call arisum             ; n arisum(n-1)
        iadd                    ; n+arisum(n-1)
ret:    return
