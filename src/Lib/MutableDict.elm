module Lib.MutableDict
    ( MutableDict
    , empty
    , insert
    , get
    , unsafeGet
    , fromList
    ) where

import Native.MutableDict
-- import Basics exposing (..)
-- import Maybe exposing (..)
-- import List


-- import ElmTest exposing (..)


type MutableDict a b = MutableDict


empty : MutableDict keyType valueType
empty =
  Native.MutableDict.empty

fromList : List (keyType, valueType) -> MutableDict keyType valueType
fromList list =
  Native.MutableDict.fromList list

get : keyType -> MutableDict keyType valueType -> Maybe valueType
get key dict =
  Native.MutableDict.get key dict

unsafeGet : keyType -> MutableDict keyType valueType -> valueType
unsafeGet key dict =
  case Native.MutableDict.get key dict of
    Just value -> value
    Nothing -> Debug.crash("Dict does not have key `" ++ toString(key) ++ "`")

insert : keyType -> valueType -> MutableDict keyType valueType
         -> MutableDict keyType valueType
insert key value dict =
  Native.MutableDict.insert key value dict

-- empty : MutableDict keyType valueType
-- empty =
--   Native.MutableDict.empty

-- initialize : Int -> (Int -> a) -> MutableDict a
-- initialize =
--   Native.MutableDict.initialize
--
-- repeat : Int -> a -> MutableDict a
-- repeat n e =
--   initialize n (always e)
--
--
-- map : (a -> b) -> MutableDict a -> MutableDict b
-- map =
--   Native.MutableDict.map
--
--
--
--
-- set : Int -> a -> MutableDict a -> MutableDict a
-- set =
--   Native.MutableDict.set
--
--
-- length : MutableDict a -> Int
-- length =
--   Native.MutableDict.length


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
