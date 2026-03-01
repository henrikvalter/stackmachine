
module Vhdl_interface(run_vhdl_testbench) where

import Asmlang.Abs as Abs
import System.Process
import Assembler
import System.IO
import Data.List
import Programs

parse_line :: String -> Maybe String
parse_line "" = Nothing
parse_line cs
    | isPrefixOf prefix cs = Just (drop (length prefix) cs)
    | otherwise = parse_line (tail cs)
    where prefix = "(report note): "

parse_lines :: [String] -> [String]
parse_lines ls = [s | Just s <- maybe_strings]
    where maybe_strings = map parse_line ls

run_vhdl_testbench :: [String] -> IO [String]
run_vhdl_testbench assembly_lines = do
    withFile "pgm.asm" WriteMode $ \h ->
        mapM (hPutStrLn h) assembly_lines
    output <- readProcess "./run_stack_machine.sh" ["pgm.asm"] ""
    return (parse_lines (lines output))

main =
    case assemble program_fibonacci of
        Left err -> putStrLn err
        Right assembly_lines -> do
            result <- run_vhdl_testbench assembly_lines
            putStrLn $ show result
