module Audio.Atoms.Multiply where

import Audio.MainTypes exposing (..)


multiply : List Input -> AudioNode
multiply inputs =
    Multiply
    { id = ""
    , inputs = inputs
    , state =
        { outputValue = 0.0 }
    }

namedMultiply : String -> List Input -> AudioNode
namedMultiply id inputs =
  Multiply
    { id = id
    , inputs = inputs
    , state =
        { outputValue = 0.0 }
    }
