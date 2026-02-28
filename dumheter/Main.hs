
import Asmlang.Abs as Abs
import Assembler
import Interpreter
import Vhdl_interface

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

main :: IO ()
main =
    case assemble program of
        Left err -> putStrLn err
        Right assembly_lines -> do
            putStrLn $ "Running VHDL..."
            vhdl_result <- run_vhdl_testbench assembly_lines
            putStrLn $ "VHDL result:"
            putStrLn $ show vhdl_result
            case interpret program 1000 of
                Left err -> putStrLn $ err
                Right result -> do
                    putStrLn $ "Interpreter result:"
                    putStrLn $ show result
    where
        program = program_count_to_100
        interpreter_timeout = 1000