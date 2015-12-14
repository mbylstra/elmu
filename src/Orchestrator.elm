-- a list of records

import ReactiveAudio exposing (sawWave)


type AudioFunction =
    Generator (Float -> Float)

type Output =
    Destination
    | ID String


type alias AudioNode =
    { id : String
    , output: Output -- this could be a union type with AudioNode
    , function: AudioFunction
    }


type alias NodeGraph = List AudioNode

graph : NodeGraph
graph =
    [ { id = "saw1"
      , output = Destination
      , function =  Generator sawWave
      }
    , { id = "saw1"
      , output = Destination
      , function =  Generator sawWave
      }
    ]
