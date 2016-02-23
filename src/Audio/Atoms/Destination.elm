module Audio.Atoms.Destination (destination) where

import Dict exposing(Dict)
import Audio.MainTypes exposing (..)

destination : String -> (AudioNode uiModel)
destination userId =
  Destination
    ( { userId = Nothing
      , autoId = Just "Nothing"  -- the destination always has id Nothing
      , inputs = Dict.fromList
        [ ("A", ID userId)
        ]
      , outputValue = 0.0
      }
    , ()
    )
