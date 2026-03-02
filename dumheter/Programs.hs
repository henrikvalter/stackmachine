
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

program_counterexample1 :: Pgm
program_counterexample1 = PDefs [PInst (Iipush 558564),PInst (Iistore (Aaddress 2)),PInst (Iipush (-1026204)),PInst (Iistore (Aaddress 10)),PInst (Iipush 892420),PInst (Iistore (Aaddress 3)),PInst (Iipush 877851),PInst (Iistore (Aaddress 9)),PInst (Iipush 936857),PInst (Iistore (Aaddress 7)),PInst (Iipush (-669223)),PInst (Iistore (Aaddress 8)),PLabel (Llabel (Ident "L6")),PInst (Iipush (-2)),PInst (Iiload (Aaddress 10)),PInst (Iipush 5),PInst (Iiload (Aaddress 7)),PInst (Iipush 11),PInst (Iistore (Aaddress 8)),PInst (Iiload (Aaddress 3)),PInst Inop,PInst (Iipush 9),PInst Inop,PInst (Iipush (-10)),PLabel (Llabel (Ident "L7")),PInst (Iipush 6),PInst (Iistore (Aaddress 9)),PInst Idup,PInst (Iipush (-7)),PInst (Iipush 5),PInst Idup,PInst (Iiload (Aaddress 9)),PInst (Iipush (-1)),PInst (Iiload (Aaddress 9)),PInst (Iiload (Aaddress 9)),PInst (Iiload (Aaddress 3)),PLabel (Llabel (Ident "L5")),PInst Iiadd,PInst Iiadd,PInst (Iiload (Aaddress 8)),PInst Inop,PInst (Iiload (Aaddress 8)),PInst (Iipush 5),PInst (Iipush 6),PInst Iiprint,PInst (Iiload (Aaddress 8)),PInst (Iiload (Aaddress 10)),PInst (Iipush 4),PLabel (Llabel (Ident "L3")),PInst (Iipush (-7)),PInst (Ibne (Llabel (Ident "L7"))),PInst (Iipush (-3)),PInst (Ibne (Llabel (Ident "L10"))),PInst Iiadd,PInst (Ibeq (Llabel (Ident "L10"))),PInst Iiadd,PInst (Iiload (Aaddress 10)),PInst (Iiload (Aaddress 8)),PInst (Iipush 4),PInst (Iipush (-8)),PLabel (Llabel (Ident "L9")),PInst (Iiload (Aaddress 10)),PInst (Iipush (-1)),PInst (Ibne (Llabel (Ident "L3"))),PInst (Iiload (Aaddress 9)),PInst Iiadd,PInst (Ibne (Llabel (Ident "L5"))),PInst Idup,PInst (Iistore (Aaddress 9)),PInst Iiprint,PInst (Iistore (Aaddress 2)),PInst (Iistore (Aaddress 2)),PLabel (Llabel (Ident "L1")),PInst Iiprint,PInst (Iiload (Aaddress 7)),PInst (Iiload (Aaddress 8)),PInst Iiprint,PInst (Ibeq (Llabel (Ident "L7"))),PInst Idup,PInst Iiadd,PInst Iiprint,PInst Iiadd,PInst (Iistore (Aaddress 9)),PInst (Iistore (Aaddress 8)),PLabel (Llabel (Ident "L4")),PInst (Iipush (-1)),PInst Idup,PInst (Iipush (-10)),PInst (Ibeq (Llabel (Ident "L1"))),PInst (Iiload (Aaddress 9)),PInst Iiprint,PInst (Iiload (Aaddress 8)),PInst (Iiload (Aaddress 9)),PInst (Iipush (-4)),PInst (Ibranch (Llabel (Ident "L10"))),PInst (Iistore (Aaddress 3)),PLabel (Llabel (Ident "L8")),PInst (Iiload (Aaddress 9)),PInst (Iiload (Aaddress 7)),PInst (Iistore (Aaddress 10)),PInst Idup,PInst (Ibranch (Llabel (Ident "L1"))),PInst (Iiload (Aaddress 3)),PInst (Iiload (Aaddress 2)),PInst (Iiload (Aaddress 2)),PInst (Iiload (Aaddress 8)),PInst (Iiload (Aaddress 9)),PInst Idup,PLabel (Llabel (Ident "L2")),PInst (Iistore (Aaddress 7)),PInst (Iiload (Aaddress 2)),PInst (Iiload (Aaddress 8)),PInst Iiprint,PInst (Iiload (Aaddress 3)),PInst (Iipush 9),PInst Idup,PInst (Iiload (Aaddress 8)),PInst (Iipush (-9)),PInst (Iiload (Aaddress 9)),PInst (Iiload (Aaddress 2)),PLabel (Llabel (Ident "L11")),PInst (Iipush (-1)),PInst (Ibne (Llabel (Ident "L8"))),PInst (Iiload (Aaddress 2)),PInst Inop,PInst Inop,PInst Iiprint,PInst (Iiload (Aaddress 3)),PInst Idup,PInst (Ibranch (Llabel (Ident "L7"))),PInst (Iistore (Aaddress 10)),PInst (Iistore (Aaddress 8)),PLabel (Llabel (Ident "L10")),PInst (Ibeq (Llabel (Ident "L4"))),PInst Iiadd,PInst (Ibranch (Llabel (Ident "L2"))),PInst Idup,PInst (Ibranch (Llabel (Ident "L10"))),PInst Idup,PInst (Iipush 7),PInst (Ibranch (Llabel (Ident "L7"))),PInst Iiprint,PInst (Iipush 11),PInst Iiadd,PInst Iexit]

test_programs :: [(String, Pgm)]
test_programs = [
    ("count_to_100", program_count_to_100),
    ("stack_error", program_stack_error),
    ("stack_error2", program_stack_error2),
    ("branch", program_branch),
    ("powers_of_2", program_powers_of_2),
    ("fibonacci", program_fibonacci),
    ("counterexample1", program_counterexample1)
    ]
