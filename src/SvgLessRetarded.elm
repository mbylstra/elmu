module SvgLessAnnoying where

import SVG.Attributes exposing (..)

x : Float -> Attribute
x =  attribute withDefault 0.0 (toFloat



{-| Declare the width of a `canvas`, `embed`, `iframe`, `img`, `input`,
`object`, or `video`.
-}

width value =
  stringProperty "width" (toString value)
