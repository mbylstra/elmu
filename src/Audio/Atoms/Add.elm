module Audio.Atoms.Add where

import Audio.MainTypes exposing (..)


add : List Input -> AudioNode
add inputs =
  Add
    { id = ""
    , inputs = inputs
    , state =
        { outputValue = 0.0 }
    }

namedAdd : String -> List Input -> AudioNode
namedAdd id inputs =
  Add
    { id = id
    , inputs = inputs
    , state =
        { outputValue = 0.0 }
    }
