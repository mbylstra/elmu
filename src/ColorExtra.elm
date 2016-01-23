module ColorExtra where

import Color exposing (Color, toHsl)
import List

compareLightness : Color -> Color -> Order
compareLightness colorA colorB =
  let
    lightnessA = .lightness (toHsl colorA)
    lightnessB = .lightness (toHsl colorB)
  in
    if lightnessA > lightnessB
    then GT
      else
        if lightnessA == lightnessB
        then EQ
        else LT

isLighter : Color -> Color -> Bool
isLighter colorA colorB =
  case (compareLightness colorA colorB) of
    GT -> True
    _ -> False

sortByLightness : List Color -> List Color
sortByLightness colors =
  List.sortWith compareLightness colors



  -- =
  --   List.sort
