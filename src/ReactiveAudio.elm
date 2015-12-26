module ReactiveAudio where

import Debug exposing (log)

import AudioNodes exposing (squareWave, OscillatorType(Square), oscillator)

import Array exposing(Array)

import Orchestrator exposing
    ( DictGraph
    , ListGraph
    , toDict
    , AudioNode(Generator, Destination, Mixer)
    , Input(ID)
    , updateGraph
    )

type alias Buffer = Array Float

type alias BufferState =
    { time: Float
    , graph: DictGraph
    , buffer: Buffer
    , bufferIndex: Int
    }


initialBuffer : Array Float
initialBuffer = Array.repeat bufferSize 0.0


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
{-         _ = Debug.log "sampleCuration" sampleDuration
        _ = Debug.log "updateBufferState time" time -}


        -- surely we can do this without having to manually create a counter?
        -- we can just iterate over the last buffer, and ignore values

        prevBuffer = prevBufferState.buffer
        initialBufferState =
            { time = time
            , graph = initialGraph
            , buffer = prevBuffer
            , bufferIndex = 0
            }

        updateForSample {time, graph, buffer, bufferIndex} =
            let
                newTime  = time + sampleDuration
--                 _ = Debug.log "udpateForSample newTime" newTime
                (newGraph, value) = updateGraph graph newTime
                newBufferIndex = bufferIndex + 1
--                 _ = Debug.log "newBufferIndex" newBufferIndex
--                 _ = Debug.log "value" value
            in
                { time  = newTime
                , graph = newGraph
                , buffer = Array.set newBufferIndex value buffer
                , bufferIndex = newBufferIndex
                }
    in
        foldn updateForSample initialBufferState bufferSize


squareA =
    Generator
        { id = "squareA"
        , function = oscillator Square 444.0
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
    [ Generator
        { id = "squareB"
        , function = oscillator Square 200.0
        , state =
            { processed = False, outputValue = 0.0  }
        }
    , Generator
        { id = "squareA"
        , function = oscillator Square 300.0
        , state =
            { processed = False, outputValue = 0.0  }
        }
    , Mixer
        { id = "mixer"
        , inputs = [ID "squareA", ID "squareB"]
        , state =
            { processed = False , outputValue = 0.0 }
        }
    , Destination
        { id = "destinationA"
        , input = ID "mixer"
        , state =
            { processed = False, outputValue = 0.0 }
        }
    ]

testGraphDict = toDict testGraph
initialBufferState =
    { time = 0.0
    , graph = testGraphDict
    , buffer = initialBuffer
    , bufferIndex = 0
    }


bufferStateSignal : Signal BufferState
bufferStateSignal = Signal.foldp updateBufferState initialBufferState requestBuffer


{- getSampleTime : Int -> Float -> Float
getSampleTime bufferIndex bufferStartTime =
    let
        _ = Debug.log "bufferIndex" bufferStartTime

    in
        bufferStartTime + (toFloat bufferIndex * sampleDuration) -}







port latestBuffer : Signal (Array Float)
port latestBuffer = Signal.map .buffer bufferStateSignal



