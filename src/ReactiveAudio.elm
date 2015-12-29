module ReactiveAudio where

import Debug exposing (log)

import AudioNodes exposing
    ( squareWave
    , OscillatorType(Square, Saw, Sin)
    , oscillator
    , simpleLowPassFilter
    , sinWave
    )

import Array exposing(Array)

import Orchestrator exposing
    ( DictGraph
    , ListGraph
    , toDict
    , AudioNode(Oscillator, Destination, Add, FeedforwardProcessor, Gain)
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




{- lowPassNode id inputName =
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
        } -}

sinNode id {frequency, frequencyOffset, phaseOffset} =
  Oscillator
    { id = id
    , function = sinWave
    , inputs = { frequency = frequency, frequencyOffset = frequencyOffset, phaseOffset = phaseOffset }
    , state =
        { outputValue = 0.0, phase = 0.0  }
    }

gainNode id {signal, gain} =
    Gain
        { id = id
        , function = AudioNodes.gain
        , inputs = { signal = signal, gain = gain }
        , state =
            { outputValue = 0.0 }
        }

adderNode id inputs =
    Add
        { id = id
        , inputs = inputs
        , state =
            { outputValue = 0.0 }
        }

destinationNode {signal} =
    Destination
        { id = "destination"
        , input = signal
        , state =
            { outputValue = 0.0 }
        }


commaHelper =
  sinNode "dummy123456789" {frequency = Default, frequencyOffset = Default, phaseOffset = Default }






testGraph : ListGraph
testGraph =
    [ commaHelper

{-     , sinNode "mod3'" {frequency = Value 200.0, frequencyOffset = Default, phaseOffset = Default}
    , gainNode "mod3" {signal = ID "mod3'", gain = Value 70.0}

    , sinNode "mod2'" {frequency = Value 800.0, frequencyOffset = ID "mod3" , phaseOffset = Default}
    , gainNode "mod2" {signal = ID "mod2'", gain = Value 5000.0}

    , sinNode "mod1'" {frequency = Value 400.0, frequencyOffset = ID "mod2", phaseOffset = Default}
    , gainNode "mod1" {signal = ID "mod1'", gain = Value 200.0} -}

{-     , sinNode "mod3'" {frequency = Value 200.0, frequencyOffset = Default, phaseOffset = Default}
    , gainNode "mod3" {signal = ID "mod3'", gain = Value 70.0}

    , sinNode "mod2'" {frequency = Value 800.0, frequencyOffset = ID "mod3" , phaseOffset = Default}
    , gainNode "mod2" {signal = ID "mod2'", gain = Value 5000.0} -}

{-     , sinNode "mod1" {frequency = Value 11025.0, frequencyOffset = Default, phaseOffset = Default}
--     , gainNode "mod1" {signal = ID "mod1'", gain = Value 200.0}
    , sinNode "root1" {frequency = Value 11025.0, frequencyOffset = Default, phaseOffset = ID "mod1"} -}

--     , sinNode "mod2" {frequency = Value 345.0, frequencyOffset = Default, phaseOffset = Default}
{-     , sinNode "mod1" {frequency = Value 11025.0, frequencyOffset = Value 666.0, phaseOffset = Default}
    , sinNode "root1" {frequency = Value 11025.0, frequencyOffset = Default, phaseOffset = ID "mod1"} -}
--     , sinNode "root1" {frequency = Value 440.0, frequencyOffset = Default, phaseOffset = Default}

    , sinNode "mod6" {frequency = Value 200.0, frequencyOffset = Value 666.0, phaseOffset = Default}
    , sinNode "mod5" {frequency = Value 200.0, frequencyOffset = Value 666.0, phaseOffset = ID "mod6"}
    , sinNode "mod4" {frequency = Value 200.0, frequencyOffset = Value 666.0, phaseOffset = ID "mod5"}
    , sinNode "mod3" {frequency = Value 400.0, frequencyOffset = Value 666.0, phaseOffset = ID "mod4"}
    , sinNode "mod2" {frequency = Value 200.0, frequencyOffset = Value 666.0, phaseOffset = ID "mod3"}
    , sinNode "mod1" {frequency = Value 100.0, frequencyOffset = Value 666.0, phaseOffset = ID "mod2"}
    , sinNode "root1" {frequency = Value 200.0, frequencyOffset = Default, phaseOffset = ID "mod1"}


    , destinationNode {signal = ID "root1"}

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



