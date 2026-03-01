
import Asmlang.Abs as Abs
import Test
import Vhdl_interface

main :: IO ()
main = do
    compile_vhdl_stackmachine
    run_unit_tests
