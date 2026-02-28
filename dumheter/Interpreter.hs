
module Interpreter(interpret) where

import Asmlang.Abs as Abs
import Data.Map

program_count_to_100 :: [Primitive]
program_count_to_100 = [
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

program_stack_error :: [Primitive]
program_stack_error = [
    PInst $ Iipush 5,
    PInst $ Iiadd,
    PInst $ Iexit
    ]

program_stack_error2 :: [Primitive]
program_stack_error2 = [
    PLabel $ Llabel $ Ident "START",
    PInst $ Iipush 5,
    PInst $ Ibne $ Llabel $ Ident "START",
    PInst $ Iexit
    ]

program_branch :: [Primitive]
program_branch = [
    PLabel $ Llabel $ Ident "START",
    PInst $ Iipush 3,
    PInst $ Iiprint,
    PInst $ Ibranch $ Llabel $ Ident "START",
    PInst $ Iexit
    ]

example_program :: Pgm
example_program = PDefs program_count_to_100

type Stack a = [a]

data Env = Env {
    program_map :: Map Integer Primitive,
    label_map :: Map Label Integer,
    pc :: Integer,
    stack :: Stack Integer,
    output :: [String],
    timeout :: Integer
} deriving Show

make_label_map :: [Primitive] -> Either String (Map Label Integer)
make_label_map primitives = helper primitives 0 empty where
    helper :: [Primitive] -> Integer -> Map Label Integer -> Either String (Map Label Integer)
    helper [] _ lmap = Right lmap
    helper ((PInst _):ps) idx lmap = helper ps (idx+1) lmap
    helper ((PLabel l):ps) idx lmap =
        if member l lmap then
            Left $ "Duplicate label " ++ show l
        else
            helper ps (idx+1) (insert l idx lmap)

make_program_map :: [Primitive] -> Map Integer Primitive
make_program_map primitives = fromList $ zip ([0..(toInteger (length primitives)-1)]) primitives

empty_env :: Pgm -> Integer -> Either String Env
empty_env (PDefs primitives) timeout =
    case make_label_map primitives of
        Left err -> Left err
        Right lmap ->
            Right (Env
                { program_map = make_program_map primitives
                , label_map = lmap
                , pc = 0
                , stack = []
                , output = []
                , timeout = timeout
                })

fetch :: Env -> Either String Primitive
fetch env =
    case Data.Map.lookup (pc env) (program_map env) of
        Nothing -> Left "Fetch error"
        Just primitive -> Right primitive

lookup_label :: Env -> Label -> Either String Integer
lookup_label env label =
    case Data.Map.lookup label (label_map env) of
        Nothing -> Left "Label lookup error"
        Just address -> Right address

assert_stack_size_geq :: Stack a -> Int -> Either String (Stack a)
assert_stack_size_geq stack size =
    if length stack < size then
        Left "Stack error"
    else
        Right stack

interpret' :: Env -> Either String Env
interpret' env =
    case timeout env of
        0 -> Right env {output = output env ++ ["timeout"]}
        _ ->
            case fetch env' of
                Left err -> Left err
                Right primitive ->
                    case primitive of
                        PLabel _ -> interpret' (env' {pc = pc env' + 1})
                        PInst Inop -> interpret' (env' {pc = pc env' + 1})
                        PInst (Iipush i) ->
                            interpret' (env' {
                                pc = pc env' + 1,
                                stack = i : stack env'
                                })
                        PInst Iiadd -> do
                            assert_stack_size_geq (stack env') 2
                            interpret' (env' {
                                pc = pc env' + 1,
                                stack = ((stack env' !! 1) + (stack env' !! 0)) : (Prelude.drop 2 (stack env'))
                                })
                        PInst Iiprint -> do
                            assert_stack_size_geq (stack env') 1
                            interpret' (env' {
                                pc = pc env' + 1,
                                stack = tail (stack env'),
                                output = output env' ++ [show (head (stack env'))]
                                })
                        PInst (Ibranch label) -> do
                            address <- lookup_label env' label
                            interpret' (env' {pc = address})
                        PInst Idup -> do
                            assert_stack_size_geq (stack env') 1
                            interpret' (env' {
                                pc = pc env' + 1,
                                stack = (head (stack env')) : (stack env')
                                })
                        PInst (Ibeq label) -> do
                            assert_stack_size_geq (stack env') 2
                            label_address <- lookup_label env' label
                            let chosen_address =
                                    if (stack env' !! 1) == (stack env' !! 0) then
                                        label_address
                                    else
                                        pc env' + 1
                            interpret' (env' {
                                pc = chosen_address,
                                stack = Prelude.drop 2 (stack env')
                                })
                        PInst (Ibne label) -> do
                            assert_stack_size_geq (stack env') 2
                            label_address <- lookup_label env' label
                            let chosen_address =
                                    if (stack env' !! 1) /= (stack env' !! 0) then
                                        label_address
                                    else
                                        pc env' + 1
                            interpret' (env' {
                                pc = chosen_address,
                                stack = Prelude.drop 2 (stack env')
                                })
                        PInst Iexit -> Right env'
    where
        env' = env {timeout = timeout env - 1}

interpret :: Pgm -> Integer -> Either String [String]
interpret pgm timeout = do
    initial_env <- empty_env pgm timeout
    final_env <- interpret' initial_env
    return (output final_env)

main = do
    case interpret example_program 1000 of
        Left err -> putStrLn $ err
        Right result -> do
            putStrLn $ show result
