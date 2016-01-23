module StringExtra
    ( toIntFromBase
    , hexToInt
    ) where

import Native.StringExtra

import ElmTest exposing (..)

import Graphics.Element

{-| TODO: docs! -}
toIntFromBase : Int -> String -> Result String Int
toIntFromBase =
  Native.StringExtra.toIntFromBase

hexToInt : String -> Result String Int
hexToInt = toIntFromBase 16

tests : Test
tests =
  suite ""
    [ test ""
      (assertEqual
        (Ok 15)
        (toIntFromBase 16 "F")
      )
    , test ""
      (assertEqual
        (Ok 15)
        (toIntFromBase 16 "0F")
      )
    , test ""
      (assertEqual
        (Ok 12245589)
        (toIntFromBase 16 "BADA55")
      )
    , test ""
      (assertEqual
        (Ok 12245589)
        (toIntFromBase 16 "BadA55")
      )
    , test ""
      (assertEqual
        (Ok 12245589)
        (toIntFromBase 16 "BadA55")
      )
    , test ""
      (assertEqual
        (Ok 12245589)
        (hexToInt "BADA55")
      )
    , test ""
      (assertEqual
        (Err "could not convert string 'GAG' to an Int")
        (hexToInt "GAG")
      )
    ]

main : Graphics.Element.Element
main =
    elementRunner tests
