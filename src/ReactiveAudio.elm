module ReactiveAudio where

import Debug exposing (log)

import AudioNodes exposing (squareWave)

import Orchestrator exposing
    ( DictGraph
    , ListGraph
    , toDict
    , AudioNode(Generator, Destination)
    , Input(ID)
    , updateGraph
    )

type alias Buffer = List Float

type alias BufferState =
    { time: Float
    , graph: DictGraph
    , buffer: Buffer
    }


{- a helper function -}
foldn : (a -> a) -> a -> Int -> a
foldn func initial count =
    if
        count > 0
    then
        foldn func (func initial) (count - 1)
    else
        initial


-- let's just hardcode sample rate for now (it's easier!)

port requestBuffer : Signal Bool

bufferSize = 4096

sampleRate = 44100

sampleDuration = 1.0 / sampleRate

updateBufferState : Bool -> BufferState -> BufferState
updateBufferState _ prevBufferState =

    let
        time = prevBufferState.time + sampleDuration
        initialGraph = prevBufferState.graph


        -- surely we can do this without having to manually create a counter?
        -- we can just iterate over the last buffer, and ignore values

        initialBufferState =
            { time=time
            , graph = initialGraph
            , buffer = [] --we'll build it up as we go
            }

        updateForSample {time, graph, buffer} =
            let
                time  = time + sampleDuration
                (newGraph, value) = updateGraph graph time
            in
                { time  = time
                , graph = newGraph
                , buffer = buffer ++ [value]
                }
    in
        foldn updateForSample initialBufferState bufferSize




squareA =
    Generator
        { id = "squareA"
        , function = squareWave
        , state =
            { processed = False, outputValue = 0.0  }
        }

destinationA =
    Destination
        { id = "destinationA"
        , input = ID "squareA"
        , state =
            { processed = False, outputValue = 0.0 }
        }


testGraph : ListGraph
testGraph =
    [ squareA
    , destinationA
    ]

testGraphDict = toDict testGraph
initialBufferState =
    { time = 0.0
    , graph = testGraphDict
    , buffer = []
    }


bufferStateSignal : Signal BufferState
bufferStateSignal = Signal.foldp updateBufferState initialBufferState requestBuffer


getSampleTime : Int -> Float -> Float
getSampleTime bufferIndex bufferStartTime =
    bufferStartTime + (toFloat bufferIndex * sampleDuration)







port latestBuffer : Signal (List Float)
port latestBuffer = Signal.map .buffer bufferStateSignal



