
import Asmlang.Abs as Abs
import Assembler
import Interpreter
import Vhdl_interface
import Test.QuickCheck
import Programs
import Test

main :: IO ()
main = run_unit_tests

--     case assemble program of
--         Left err -> putStrLn err
--         Right assembly_lines -> do
--             putStrLn $ "Running VHDL..."
--             vhdl_result <- run_vhdl_testbench assembly_lines
--             putStrLn $ "VHDL result:"
--             putStrLn $ show vhdl_result
--             case interpret program interpreter_timeout of
--                 Left err -> putStrLn $ err
--                 Right result -> do
--                     putStrLn $ "Interpreter result:"
--                     putStrLn $ show result
--     where
--         program = program_count_to_100
--         interpreter_timeout = 1000