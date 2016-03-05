module Lib.StringKeyMutableDict
    ( StringKeyMutableDict
    , empty
    , insert
    , get
    , unsafeGet
    , unsafeNativeGet
    , fromList
    , toList
    , values
    , keys
    ) where

import Native.StringKeyMutableDict
-- import Basics exposing (..)
-- import Maybe exposing (..)
-- import List


-- import ElmTest exposing (..)


type StringKeyMutableDict valueType = StringKeyMutableDict


empty : () -> StringKeyMutableDict valueType
empty =
  Native.StringKeyMutableDict.empty

fromList : List (String, valueType) -> StringKeyMutableDict valueType
fromList list =
  Native.StringKeyMutableDict.fromList list

toList : StringKeyMutableDict valueType -> List (String, valueType)
toList dict =
  Native.StringKeyMutableDict.toList dict

get : String -> StringKeyMutableDict valueType -> Maybe valueType
get key dict =
  Native.StringKeyMutableDict.get key dict

unsafeGet : String -> StringKeyMutableDict valueType -> valueType
unsafeGet key dict =
  case Native.StringKeyMutableDict.get key dict of
    Just value -> value
    Nothing -> Debug.crash("Dict does not have key `" ++ toString(key) ++ "`")

unsafeNativeGet : String -> StringKeyMutableDict valueType -> valueType
unsafeNativeGet key dict =
  Native.StringKeyMutableDict.unsafeNativeGet key dict

insert : String -> valueType -> StringKeyMutableDict valueType
         -> StringKeyMutableDict valueType
insert key value dict =
  Native.StringKeyMutableDict.insert key value dict

values : StringKeyMutableDict valueTupe -> List valueType
values dict =
  Native.StringKeyMutableDict.values dict

keys : StringKeyMutableDict valueTupe -> List valueType
keys dict =
  Native.StringKeyMutableDict.keys dict

-- empty : StringKeyMutableDict keyType valueType
-- empty =
--   Native.StringKeyMutableDict.empty

-- initialize : Int -> (Int -> a) -> StringKeyMutableDict a
-- initialize =
--   Native.StringKeyMutableDict.initialize
--
-- repeat : Int -> a -> StringKeyMutableDict a
-- repeat n e =
--   initialize n (always e)
--
--
-- map : (a -> b) -> StringKeyMutableDict a -> StringKeyMutableDict b
-- map =
--   Native.StringKeyMutableDict.map
--
--
--
--
-- set : Int -> a -> StringKeyMutableDict a -> StringKeyMutableDict a
-- set =
--   Native.StringKeyMutableDict.set
--
--
-- length : StringKeyMutableDict a -> Int
-- length =
--   Native.StringKeyMutableDict.length


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
