
module Programs where

import Asmlang.Abs as Abs

program_count_to_100 :: Pgm
program_count_to_100 = PDefs [
    PInst $ Iipush 0,
    PLabel $ Llabel $ Ident "LOOP",
    PInst $ Idup,
    PInst $ Iiprint,
    PInst $ Iipush 1,
    PInst $ Iiadd,
    PInst $ Idup,
    PInst $ Iipush 100,
    PInst $ Ibne $ Llabel $ Ident "LOOP",
    PInst $ Iexit
    ]

program_stack_error :: Pgm
program_stack_error = PDefs [
    PInst $ Iipush 5,
    PInst $ Iiadd,
    PInst $ Iexit
    ]

program_stack_error2 :: Pgm
program_stack_error2 = PDefs [
    PLabel $ Llabel $ Ident "START",
    PInst $ Iipush 5,
    PInst $ Ibne $ Llabel $ Ident "START",
    PInst $ Iexit
    ]

program_branch :: Pgm
program_branch = PDefs [
    PLabel $ Llabel $ Ident "START",
    PInst $ Iipush 3,
    PInst $ Iiprint,
    PInst $ Ibranch $ Llabel $ Ident "START",
    PInst $ Iexit
    ]

program_powers_of_2 :: Pgm
program_powers_of_2 = PDefs [
    PInst $ Iipush 2,
    PLabel $ Llabel $ Ident "LOOP",
    PInst $ Idup,
    PInst $ Iiprint,
    PInst $ Idup,
    PInst $ Iiadd,
    PInst $ Idup,
    PInst $ Iipush 2048,
    PInst $ Ibeq $ Llabel $ Ident "END",
    PInst $ Ibranch $ Llabel $ Ident "LOOP",
    PLabel $ Llabel $ Ident "END",
    PInst $ Iiprint,
    PInst $ Iexit
    ]

program_fibonacci :: Pgm
program_fibonacci = PDefs [
    PInst  $ Iipush 2,
    PInst  $ Iistore (Aaddress 2),
    PInst  $ Iipush 1,
    PInst  $ Idup,
    PInst  $ Iiprint,
    PInst  $ Iistore (Aaddress 0),
    PInst  $ Iipush 1,
    PInst  $ Idup,
    PInst  $ Iiprint,
    PInst  $ Iistore (Aaddress 1),
    PLabel $ Llabel $ Ident "LOOP",
    PInst  $ Iiload (Aaddress 0),
    PInst  $ Iiload (Aaddress 1),
    PInst  $ Idup,
    PInst  $ Iistore (Aaddress 0),
    PInst  $ Iiadd,
    PInst  $ Idup,
    PInst  $ Iiprint,
    PInst  $ Iistore (Aaddress 1),
    PInst  $ Iiload (Aaddress 2),
    PInst  $ Iipush 1,
    PInst  $ Iiadd,
    PInst  $ Idup,
    PInst  $ Iistore (Aaddress 2),
    PInst  $ Iipush 30,
    PInst  $ Ibne $ Llabel $ Ident "LOOP",
    PInst  $ Iexit
    ]

test_programs :: [(String, Pgm)]
test_programs = [
    ("count_to_100", program_count_to_100),
    ("stack_error", program_stack_error),
    ("stack_error2", program_stack_error2),
    ("branch", program_branch),
    ("powers_of_2", program_powers_of_2),
    ("fibonacci", program_fibonacci)
    ]
