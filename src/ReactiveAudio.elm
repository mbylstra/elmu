module ReactiveAudio where

import Debug exposing (log)

import AudioNodes exposing
    ( squareWave
    , OscillatorType(Square, Saw, Sin)
    , oscillator
    , simpleLowPassFilter
    , sinWave
    , gain
    )

import Array exposing(Array)

import Orchestrator exposing
    ( DictGraph
    , ListGraph
    , toDict
    , AudioNode(Oscillator, Destination, Mixer, FeedforwardProcessor, Gain)
    , Input(ID, Default, Value)
    , updateGraph
    )

type alias Buffer = Array Float

type alias BufferState =
    { time: Float
    , graph: DictGraph
    , buffer: Buffer
    , bufferIndex: Int
    }






{- type alias Positioned a =
    { a | x : Float, y : Float } -}


{- type alias EmptyRecord a =
    { a |  x : Float} -}

type alias EmptyRecord =
    { }


type alias Positioned a =
  { a | x : Float, y : Float }

type alias Named a =
  { a | name : String }

type alias Moving a =
  { a | velocity : Float, angle : Float }


type alias Something = Named  (Moving  ( Positioned EmptyRecord))


-- type alias Asdf (Positioned {})

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


{- squareA =
    Generator
        { id = "squareA"
        , function = oscillator Square 444.0
        , state =
            { outputValue = 0.0  }
        } -}



destinationA =
    Destination
        { id = "destinationA"
        , input = ID "squareA"
        , state =
            { outputValue = 0.0 }
        }

{- makeSquare id frequency =
    Generator
        { id = id
        , function = oscillator Saw frequency
        , state =
            { outputValue = 0.0  }
        } -}

{- makeSin id frequency =
    Generator
        { id = id
        , function = oscillator Sin frequency
        , state =
            { outputValue = 0.0  }
        } -}


makeLowPass id inputName =
    FeedforwardProcessor
        { id = id
        , input = ID inputName
        , function = simpleLowPassFilter
        , state =
            { outputValue = 0.0
--             , prevValues = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
            , prevValues =  List.repeat 2 0.0
--             , prevValues = [0.0, 0.0, 0,0]
            }
        }




testGraph : ListGraph
testGraph =
--     [ makeSquare "osc"  11025.0
    [
{-        Oscillator
        { id = "osc4"
        , function = sinWave
        , inputs = { frequency = Value 300.01, phaseOffset = Default }
        , state =
            { outputValue = 0.0, phase = 0.0  }
        } -}
{-        Oscillator
        { id = "osc3"
        , function = sinWave
--         , inputs = { frequency = Value 50.00, phaseOffset = ID "osc4" }
        , inputs = { frequency = Value 50.00, phaseOffset = Default }
        , state =
            { outputValue = 0.0, phase = 0.0  }
        }  -}
{-       Oscillator
        { id = "osc2"
        , function = sinWave
--         , inputs = { frequency = Value 5, phaseOffset = ID "osc3"}
        , inputs = { frequency = Value 0.1, phaseOffset = Default }
        , state =
            { outputValue = 0.0, phase = 0.0  }
        } -}


      Oscillator
        { id = "osc1"
        , function = sinWave
--         , inputs = { frequency = Value 200.0, phaseOffset = ID "osc2" }
        , inputs = { frequency = Value 80.0, phaseOffset = Default }
        , state =
            { outputValue = 0.0, phase = 0.0  }
        }

    , Gain
        { id = "osc1Gain"
        , function = gain
--         , inputs = { frequency = Value 200.0, phaseOffset = ID "osc2" }
        , inputs = { signal = ID "osc1", gain = Value 1.0 }
        , state =
            { outputValue = 0.0 }
        }
--     [ makeSquare "osc"  80.0
--     , makeSquare "osc"  11025.0
      {-     , makeSquare "squareB" 250.0
    , makeSquare "squareC" 200.0 -}
{-     , Mixer
        { id = "mixer"
        , inputs = [ID "squareA", ID "squareB", ID "squareC"]
        , state =
            { outputValue = 0.0 }
        } -}
--     , makeLowPass "lowpass" "osc1"
    , Destination
        { id = "destinationA"
--         , input = ID "mixer"
        , input = ID "osc1Gain"
--         , input = ID "osc"
        , state =
            { outputValue = 0.0 }
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



