
module Vhdl_interface(compile_vhdl_stackmachine,run_vhdl_stackmachine,clean_vhdl_stackmachine) where

import Asmlang.Abs as Abs
import System.Process
import Assembler
import System.IO
import Data.List
import Programs
import Control.Monad.Trans.Except
import Control.Monad.IO.Class

parse_line :: String -> Maybe String
parse_line "" = Nothing
parse_line cs
    | isPrefixOf prefix cs = Just (drop (length prefix) cs)
    | otherwise = parse_line (tail cs)
    where prefix = "(report note): "

parse_lines :: [String] -> [String]
parse_lines ls = [s | Just s <- maybe_strings]
    where maybe_strings = map parse_line ls

compile_vhdl_stackmachine :: IO ()
compile_vhdl_stackmachine = callProcess "./vhdl_build.sh" []

write_asm_file :: [String] -> IO ()
write_asm_file assembly_lines = do
    withFile "pgm.mif" WriteMode $ \h ->
        mapM_ (hPutStrLn h) assembly_lines

run_vhdl_stackmachine :: Pgm -> IO (Either String [String])
run_vhdl_stackmachine pgm =
    runExceptT $ do
        assembly_lines <- ExceptT (return $ assemble pgm)
        liftIO $ write_asm_file assembly_lines
        output <- liftIO $ readProcess "./vhdl_run.sh" [] ""
        return $ parse_lines (lines output)

clean_vhdl_stackmachine :: IO ()
clean_vhdl_stackmachine = callProcess "./vhdl_build.sh" []

main = do
    compile_vhdl_stackmachine
    output <- run_vhdl_stackmachine program_fibonacci
    putStrLn $ show output
    clean_vhdl_stackmachine