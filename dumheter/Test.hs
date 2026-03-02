
module Test where

import Asmlang.Abs as Abs
import Assembler
import Interpreter
import Vhdl_interface
import Test.QuickCheck
import Programs
import Control.Monad.Trans.Except
import Control.Monad.IO.Class
import Test.QuickCheck
import Data.List

output_match :: [String] -> [String] -> Bool
output_match [] [] = True
output_match ("timeout":_) _ = True
output_match _ ("timeout":_) = True
output_match (head1:tail1) (head2:tail2) =
    head1 == head2 && output_match tail1 tail2

test_pgm :: Pgm -> IO (Either String Bool)
test_pgm pgm =
    runExceptT $ do
        interpreter_result <- ExceptT $ return (interpret pgm interpreter_timeout)
        vhdl_result <- ExceptT $ run_vhdl_stackmachine pgm
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

run_unit_tests :: IO ()
run_unit_tests = mapM_ unit_test test_programs

gen_pgm_nops :: Int -> Gen Pgm
gen_pgm_nops n = do
    ops <- helper n
    return $ PDefs $ ops ++ [PInst Iexit] where
        helper :: Int -> Gen [Primitive]
        helper 0 = return []
        helper n = do
            k <- chooseInt(0, n)
            return $ replicate k (PInst Inop)

{-
Idea.
1. Generate a set of labels and shuffle them.
2. Generate a set of (non-negative) data addresses and shuffle them.
3. In the generated code, initiate each data address with random data.
4. For each label, generate non-label and non-exit instructions. Concatenate.
Labels must be in the labels set and addresses from the address set.
-}

gen_pgm :: Int -> Gen Pgm
gen_pgm n = do
    -- Labels
    let label_indexes = [1..n]
    let labels = map (\i -> Llabel $ Ident $ "L" ++ show i) label_indexes
    shuffled_labels <- shuffle labels
    -- Data addresses
    data_address_ints <- listOf1 $ chooseInteger (0,toInteger n)
    let data_addresses = map Aaddress data_address_ints
    data_addresses_inits <- mapM data_address_init (nub data_addresses)
    let data_address_init_instructions = concat data_addresses_inits
    -- Label instructions
    label_instructions <- vectorOf (length labels) (gen_label_instructions labels data_addresses n)
    let labels_and_instructions =
            zipWith (\label instructions -> PLabel label : instructions)
            shuffled_labels label_instructions
    return $ PDefs $ concat [
        data_address_init_instructions,
        concat labels_and_instructions,
        [PInst Iexit]]
    where
        data_address_init :: Address -> Gen [Primitive]
        data_address_init a = do
            content <- chooseInteger (-2^20, 2^20)
            return [PInst $ Iipush content,
                    PInst $ Iistore a]
        gen_label_instructions :: [Label] -> [Address] -> Int -> Gen [Primitive]
        gen_label_instructions labels addresses = helper where
            helper :: Int -> Gen [Primitive]
            helper 0 = return []
            helper n = do
                op <- frequency [(1, return $ PInst Inop),
                                 (10, do
                                    i <- arbitrary -- int
                                    return $ PInst $ Iipush i),
                                 (2, return $ PInst Iiadd),
                                 (5, return $ PInst Iiprint),
                                 (2, do
                                    label <- elements labels
                                    return $ PInst $ Ibranch label),
                                 (5, return $ PInst Idup),
                                 (2, do
                                    label <- elements labels
                                    return $ PInst $ Ibeq label),
                                 (2, do
                                    label <- elements labels
                                    return $ PInst $ Ibne label),
                                 (15, do
                                    address <- elements addresses
                                    return $ PInst $ Iiload address),
                                 (5, do
                                    address <- elements addresses
                                    return $ PInst $ Iistore address)]
                rest <- helper (n-1)
                return $ op : rest

prop_pgm :: Pgm -> Property
prop_pgm pgm = ioProperty $ do
    result <- test_pgm pgm
    return $ case result of
        Left _  -> discard
        Right b -> property b

test_main :: IO ()
test_main = do
    compile_vhdl_stackmachine
    -- vhdl_result <- run_vhdl_stackmachine program_counterexample1
    -- print $ vhdl_result
    -- putStrLn $ show $ interpret program_counterexample1 1000
    run_unit_tests
    verboseCheck $ forAll (sized gen_pgm) prop_pgm

    -- quickCheck $ forAll (sized gen_pgms) prop_pgm
    -- sample $ sized gen_pgm

-- main :: IO ()
-- main = test_main


-- gen_ops :: Int -> Gen [Primitive]
-- gen_ops 0 = return []
-- gen_ops n = do
--   k <- chooseInt(0, n)
--   return $ replicate k (PInst Inop)
--
-- gen_ops :: Int -> Gen [Primitive]
-- gen_ops 0 = return []
-- gen_ops n = do
--   op <- frequency [(4, do
--                         i <- arbitrary -- int
--                         return $ PInst $ Iipush i),
--                    (2, return $ PInst $ Iiprint),
--                    (1, return $ PInst $ Iiadd)]
--   ops <- gen_ops (n-1)
--   return $ op : ops

-- instance Arbitrary Pgm where
--   arbitrary = do
--     is <- sized gen_ops
--     return $ PDefs is