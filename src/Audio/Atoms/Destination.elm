module Audio.Atoms.Destination (destination) where

import Lib.StringKeyMutableDict as StringKeyMutableDict exposing(StringKeyMutableDict)
import Audio.MainTypes exposing (..)

destination : String -> (AudioNode uiModel)
destination userId =
  Destination
    identity
    { userId = Nothing
    , autoId = Just "Nothing"
    , inputs = StringKeyMutableDict.fromList
      [ ("A", ID userId)
      ]
    }
    (initialiseDynamicBaseProps ())
