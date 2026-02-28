
import Asmlang.Abs as Abs
import Data.Map
import Data.Bits
import Data.Word

to_b32 :: Integer -> String
to_b32 n =
    [ if testBit w i then '1' else '0'
    | i <- [31,30..0]
    ]
  where
    w = fromIntegral n :: Word32

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

data EOL = EOLString String | EOLLabel Label
    deriving (Show, Eq)

data EOLMap = EOLMap {
    eolmap :: Map Integer EOL,
    next :: Integer
} deriving Show

empty_eolmap :: EOLMap
empty_eolmap = EOLMap
    { eolmap = empty
    , next = 0
    }

eolmap_insert :: EOLMap -> EOL -> EOLMap
eolmap_insert emap eol = emap {eolmap = insert (next emap) eol (eolmap emap), next = next emap + 1}

example_program :: [Primitive]
example_program = program_count_to_100

label2string :: Label -> String
label2string (Llabel (Ident s)) = s

first_pass :: Pgm -> Either String (EOLMap, Map Label Integer)
first_pass (PDefs primitives) = helper primitives empty_eolmap empty where
    helper :: [Primitive] -> EOLMap -> Map Label Integer -> Either String (EOLMap, Map Label Integer)
    helper [] eolmap lmap = Right (eolmap, lmap)
    helper (p:ps) eolmap lmap =
        case p of
            PLabel label ->
                if member label lmap then
                    Left $ "Duplicate label " ++ show label
                else
                    helper ps eolmap (insert label (next eolmap) lmap)
            PInst Inop ->
                helper ps eolmap1 lmap where
                    eolmap1 = eolmap_insert eolmap (EOLString $ (to_b32 0x0) ++ " -- nop")
            PInst (Iipush i) ->
                helper ps eolmap2 lmap where
                    eolmap1 = eolmap_insert eolmap  (EOLString $ (to_b32 0x1) ++ " -- ipush " ++ show i)
                    eolmap2 = eolmap_insert eolmap1 (EOLString $ (to_b32 i))
            PInst Iiadd ->
                helper ps eolmap1 lmap where
                    eolmap1 = eolmap_insert eolmap (EOLString $ (to_b32 0x2) ++ " -- iadd")
            PInst Iiprint ->
                helper ps eolmap1 lmap where
                    eolmap1 = eolmap_insert eolmap (EOLString $ (to_b32 0x3) ++ " -- iprint")
            PInst (Ibranch label) ->
                helper ps eolmap2 lmap where
                    eolmap1 = eolmap_insert eolmap (EOLString $ (to_b32 0x4) ++ " -- branch to label " ++ label2string label)
                    eolmap2 = eolmap_insert eolmap1 (EOLLabel label)
            PInst Idup ->
                helper ps eolmap1 lmap where
                    eolmap1 = eolmap_insert eolmap (EOLString $ (to_b32 0x5) ++ " -- dup")
            PInst (Ibeq label) ->
                helper ps eolmap2 lmap where
                    eolmap1 = eolmap_insert eolmap (EOLString $ (to_b32 0x6) ++ " -- branch to label " ++ label2string label ++ " if equal")
                    eolmap2 = eolmap_insert eolmap1 (EOLLabel label)
            PInst (Ibne label) ->
                helper ps eolmap2 lmap where
                    eolmap1 = eolmap_insert eolmap (EOLString $ (to_b32 0x7) ++ " -- branch to label " ++ label2string label ++ " if not equal")
                    eolmap2 = eolmap_insert eolmap1 (EOLLabel label)
            PInst Iexit ->
                helper ps eolmap1 lmap where
                    eolmap1 = eolmap_insert eolmap (EOLString $ (to_b32 (-1)) ++ " -- exit")

second_pass :: EOLMap -> Map Label Integer -> Either String [String]
second_pass emap lmap = traverse helper [0..(next emap)-1] where
    helper :: Integer -> Either String String
    helper i = case Data.Map.lookup i (eolmap emap) of
        Nothing -> Left "eolmap lookup failed"
        Just (EOLString s) -> Right s
        Just (EOLLabel l) ->
            case Data.Map.lookup l lmap of
                Nothing -> Left "label lookup failed"
                Just dst -> Right $ to_b32 (dst - i + 1)

assemble :: Pgm -> Either String [String]
assemble pgm = do
    (eolmap, lmap) <- first_pass pgm
    second_pass eolmap lmap

main =
    case assemble (PDefs program_count_to_100) of
        Left err -> putStrLn err
        Right machine_code_lines -> putStrLn $ unlines machine_code_lines

    -- putStrLn $ show $ assemble (PDefs program_count_to_100)
