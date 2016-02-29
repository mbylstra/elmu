module Lib.GenericMutableDict
    ( GenericMutableDict
    , empty
    , insert
    , unsafeNativeGet
    , fromList
    ) where

import Native.GenericMutableDict
-- import Basics exposing (..)
-- import Maybe exposing (..)
-- import List


-- import ElmTest exposing (..)


type GenericMutableDict = GenericMutableDict


empty : () -> GenericMutableDict
empty =
  Native.GenericMutableDict.empty

fromList : List (keyType, valueType) -> GenericMutableDict
fromList list =
  Native.GenericMutableDict.fromList list

--
-- get : keyType -> GenericMutableDict keyType valueType -> Maybe valueType
-- get key dict =
--   Native.GenericMutableDict.get key dict
--
-- unsafeGet : keyType -> GenericMutableDict keyType valueType -> valueType
-- unsafeGet key dict =
--   case Native.GenericMutableDict.get key dict of
--     Just value -> value
--     Nothing -> Debug.crash("Dict does not have key `" ++ toString(key) ++ "`")
--

unsafeNativeGet : keyType -> GenericMutableDict -> valueType
unsafeNativeGet key dict =
  Native.GenericMutableDict.unsafeNativeGet key dict

insert : keyType -> valueType -> GenericMutableDict -> ()
insert key value dict =
  Native.GenericMutableDict.insert key value dict


-- empty : GenericMutableDict keyType valueType
-- empty =
--   Native.GenericMutableDict.empty

-- initialize : Int -> (Int -> a) -> GenericMutableDict a
-- initialize =
--   Native.GenericMutableDict.initialize
--
-- repeat : Int -> a -> GenericMutableDict a
-- repeat n e =
--   initialize n (always e)
--
--
-- map : (a -> b) -> GenericMutableDict a -> GenericMutableDict b
-- map =
--   Native.GenericMutableDict.map
--
--
--
--
-- set : Int -> a -> GenericMutableDict a -> GenericMutableDict a
-- set =
--   Native.GenericMutableDict.set
--
--
-- length : GenericMutableDict a -> Int
-- length =
--   Native.GenericMutableDict.length


-- type TestEnum = Alpha | Beta | Gamma
--
--
-- tests : Test
-- tests =
--
--     suite ""
--         [
--           test ""
--             (assertEqual
--                 -- (repeat 5 0)
--                 -- (repeat 5 0)
--                 ( empty
--                 )
--                 empty
--             )
--         , test ""
--             (assertEqual
--                 -- (repeat 5 0)
--                 -- (repeat 5 0)
--                 ( fromList [(Alpha, 1), (Beta, 2)]
--                 )
--                 ( fromList [(Alpha, 1), (Beta, 2)]
--                 )
--             )
--         , test ""
--             (assertEqual
--                 -- (repeat 5 0)
--                 -- (repeat 5 0)
--                 ( get Alpha (fromList [(Alpha, 1)])
--                 )
--                 1
--             )
--         ]

-- main : Graphics.Element.Element
-- main =
--     elementRunner tests
