module Audio.Atoms.Destination (destination) where

import Dict exposing(Dict)
import Audio.MainTypes exposing (..)

destination : String -> (AudioNode uiModel)
destination userId =
  Destination
    { userId = Nothing
    , autoId = Just "Nothing"
    , inputs = Dict.fromList
      [ ("A", ID userId)
      ]
    }
    (initialiseDynamicBaseProps ())
