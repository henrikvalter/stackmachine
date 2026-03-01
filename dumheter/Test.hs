
--module Test
--    ( output_match
--    , test_pgm
--    , unit_test
--    , run_unit_tests
--    ) where

import Asmlang.Abs as Abs
import Assembler
import Interpreter
import Vhdl_interface
import Test.QuickCheck
import Programs
import Control.Monad.Trans.Except
import Control.Monad.IO.Class
import Test.QuickCheck

output_match :: [String] -> [String] -> Bool
output_match [] [] = True
output_match ("timeout":_) _ = True
output_match _ ("timeout":_) = True
output_match (head1:tail1) (head2:tail2) =
    head1 == head2 && output_match tail1 tail2

test_pgm :: Pgm -> IO (Either String Bool)
test_pgm program =
    runExceptT $ do
        assembly_lines <- ExceptT $ return (assemble program)
        interpreter_result <- ExceptT $ return (interpret program interpreter_timeout)
        vhdl_result <- liftIO $ run_vhdl_stackmachine assembly_lines
        return $ output_match interpreter_result vhdl_result
    where
        interpreter_timeout = 1000

unit_test :: (String,Pgm) -> IO ()
unit_test (name,pgm) = do
    result <- test_pgm pgm
    case result of
        Left err -> putStrLn $ "Program " ++ name ++ " failed. Error: " ++ show err
        Right result -> do
            if result then
                putStrLn $ "Program " ++ name ++ ": ok."
            else
                putStrLn $ "Program " ++ name ++ ": output mismatch."

instance Arbitrary Pgm where
  arbitrary = do
    is <- sized gen_ops1
    return $ PDefs (is ++ [PInst Iexit])

gen_ops0 :: Int -> Gen [Primitive]
gen_ops0 0 = return []
gen_ops0 n = do
  k <- chooseInt(0, n)
  return $ replicate k (PInst Inop)

gen_ops1 :: Int -> Gen [Primitive]
gen_ops1 0 = return []
gen_ops1 n = do
  op <- frequency [(4, do
                        i <- arbitrary -- int
                        return $ PInst $ Iipush i),
                   (2, return $ PInst $ Iiprint),
                   (1, return $ PInst $ Iiadd)]
  ops <- gen_ops1 (n-1)
  return $ op : ops

prop_pgm :: Pgm -> Property
prop_pgm pgm = ioProperty $ do
    result <- test_pgm pgm
    return $ case result of
        Left _  -> discard
        Right b -> property b

run_unit_tests :: IO ()
run_unit_tests = mapM_ unit_test test_programs

main :: IO ()
main = do
    compile_vhdl_stackmachine
    run_unit_tests
    quickCheck prop_pgm
