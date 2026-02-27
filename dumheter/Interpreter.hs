
import Asmlang.Abs as Abs
import Control.Monad.State

example_program :: [Primitive]
example_program = [
    -- PInst $ Iipush 100,
    -- PInst $ Iipush 22,
    -- PInst $ Iiadd,
    -- PInst $ Iiprint,
    -- PInst $ Iexit
    PInst $ Iipush 100,
    PInst $ Iipush 200,
    PInst $ Iipush 300,
    PInst $ Iiadd,
    PInst $ Iiadd,
    -- PInst $ Iiadd,
    PInst $ Iiprint,
    PInst $ Iexit
    ]

type Stack a = [a]
push :: Stack a -> a -> Stack a
push s a = a : s
pop :: Stack a -> Maybe (a, Stack a)
pop [] = Nothing
pop (a:as) = Just (a, as)

data Env = Env {
    program :: [Primitive],
    pc :: Integer,
    stack :: Stack Integer,
    output :: [String],
    timeout :: Integer
} deriving Show

fetch :: Integer -> [Primitive] -> Maybe Primitive
fetch pc pgm | (fromInteger pc) < length pgm = Just (pgm !! (fromInteger pc))
             | otherwise = Nothing

emptyEnv :: [Primitive] -> Integer -> Env
emptyEnv primitives timeout =
    Env { program = primitives
        , pc = 0
        , stack = []
        , output = []
        , timeout = timeout
        }

interpret :: Env -> Either String Env
interpret env =
    case timeout env of
        0 -> Right env {output = output env ++ ["timeout"]}
        _ ->
            case fetch (pc env') (program env') of
                Nothing -> Left "Fetch error"
                Just primitive ->
                    case primitive of
                        PLabel _ -> interpret (env' {pc = pc env' + 1})
                        PInst Inop -> interpret (env' {pc = pc env' + 1})
                        PInst (Iipush i) ->
                            interpret (env' {
                                pc = pc env' + 1,
                                stack = push (stack env') i
                                })
                        PInst Iiadd ->
                            if length (stack env') < 2 then
                                Left "Stack error"
                            else
                                interpret (env' {
                                    pc = pc env' + 1,
                                    stack = push (drop 2 (stack env')) ((stack env' !! 1) + (stack env' !! 0))
                                    })
                        PInst Iiprint ->
                            if length (stack env') < 1 then
                                Left "Stack error"
                            else
                                interpret (env' {
                                    pc = pc env' + 1,
                                    stack = tail (stack env'),
                                    output = output env' ++ [show (head (stack env'))]
                                    })
                        -- ...
                        PInst Iexit -> Right env'
    where
        env' = env {timeout = timeout env - 1}


    --     case maybe_primitive of
    --         Nothing -> Left "fetch error"
    --         Just primitive -> do
    --             let newEnv =
    --                 case primitive of
    --                 PInst (Inop) -> env {pc = (pc env + 1)}
    --                 _ -> env
    --             Left "!?"


--     let prim = program env !! pc

    -- PInst (Inop) -> interpretPrims env ps
    -- PInst (Iipush i) -> do
    --     let stack0 = stack env
    --     let env1 = env {stack = stack0}
    --     interpretPrims env1 ps

    -- PInst (Iipush i) -> do
    --     stack <- stack_get
    --     stack_put (stack_push stack i)
    --     return ""
    -- PInst (Iiadd) -> do
    --     stack <- stack_get
    --     a <- stack_pop
    --     b <- stack_pop
    --     stack_put (stack_push stack (a+b))


    -- | Iiadd
    -- | Iiprint
    -- | Ibranch
    -- | Idup
    -- | Ibeq Label
    -- | Ibne Label
    -- | Iexit

    -- helper (p:ps) = case p of
    --     PInst (Inop) -> helper ps
    --     _ -> Nothing

--interpret :: Abs.Pgm -> Maybe [String]
--interpret (PDefs prims) = interpretPrims prims

main =
    case interpret (emptyEnv example_program 100) of
        Left s -> putStrLn s
        Right env -> putStrLn $ show env
