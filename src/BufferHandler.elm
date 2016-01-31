module BufferHandler where

-- import Html exposing (text)

import Gui exposing(EncodedModel, initialEncodedModel)

import Dict exposing (Dict)



-- import Debug exposing (log)

-- import Signal
-- import StartApp.Simple as StartApp

-- import Html exposing (text)
-- import Graphics.Element
-- import Graphics.Input

-- import Time exposing (Time, fps)
-- import Keyboard



import Audio.MainTypes exposing (..)
    -- ( squareWave
    -- , OscillatorType(Square, Saw, Sin)
    -- , oscillator
    -- , simpleLowPassFilter
    -- , sinWave
    -- )

-- import Gui exposing (UserInput)

import Array exposing(Array)

import Orchestrator exposing
    (
    --  ListGraph
      -- toDict
    -- , AudioNode(Oscillator, Destination, Add, FeedforwardProcessor, Gain)
    -- , Input(ID, Default, Value)
      updateGraph
    -- , ExternalState
    -- , ExternalInputState
    )

import Audio.AudioNodeFunctions exposing (getPeriodSeconds, sampleDuration, fmod)
--------------------------------------------------------------------------------
-- Types
--------------------------------------------------------------------------------

-- type GuiAction : AudioOn Bool
-- type Input = ID String | Value Float | Default   -- or it could be an AudioNode! Maybe?

type alias Buffer = Array Float

-- type alias ExternalInputState =
--     { xWindowFraction: Float
--     , yWindowFraction: Float
--     , audioOn : Bool
--     }

type alias BufferState =
    { time: Float
    , graph: DictGraph
    , buffer: Buffer
    , bufferIndex: Int
    , externalInputState: EncodedModel
    }



initialState : BufferState
initialState =
  { time = 0.0
  , graph = Dict.fromList []
  , buffer = Array.repeat bufferSize 0.0
  , bufferIndex = 0
  , externalInputState = initialEncodedModel
  }



-- type alias Asdf (Positioned {})
-- reallyDumb : String
-- reallyDumb = dummy

-- initialBuffer : Array Float
-- initialBuffer = Array.repeat bufferSize 0.0


bufferSize : Int
-- bufferSize = 1024
bufferSize = 1

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






updateBufferState : EncodedModel -> BufferState -> BufferState
updateBufferState userInput prevBufferState =

    -- let
    --   _ = Debug.log "inside" userInput
    -- in
    --   prevBufferState

    let
        externalInputState : EncodedModel
        externalInputState = userInput
        time = prevBufferState.time + sampleDuration
        initialGraph = prevBufferState.graph
        prevBuffer = prevBufferState.buffer

        initialBufferState : BufferState
        initialBufferState =
            { time = time
            , graph = initialGraph
            , buffer = prevBuffer
            , bufferIndex = 0
            , externalInputState = externalInputState
            }

        updateForSample : BufferState -> BufferState
        updateForSample {time, graph, buffer, bufferIndex} =
            let
                _ = Debug.log "updateForSample" 1
                newTime  = time + sampleDuration
                externalState =
                    { time = newTime
                    , externalInputState = externalInputState
                    }
                newBufferIndex = bufferIndex + 1
            in
                if
                    externalInputState.audioOn == True
                then
                    let
                        _ = Debug.log "asdf" 1
                        (newGraph, value) = updateGraph graph externalState
                    in
                        { time  = newTime
                        , graph = newGraph
                        , buffer = Array.set newBufferIndex value buffer
                        , bufferIndex = newBufferIndex
                        , externalInputState =  externalInputState
                        }
                else
                    { time  = newTime
                    , graph = graph
                    , buffer = Array.set newBufferIndex 0.0 buffer
                    , bufferIndex = newBufferIndex
                    , externalInputState =  externalInputState
                    }
    in
        foldn updateForSample initialBufferState bufferSize





destinationA : AudioNode
destinationA =
    Destination
        { id = "destinationA"
        , input = ID "squareA"
        , state =
            { outputValue = 0.0 }
        }











-- we won't use this any port, rather we'll use userInputSignal as a port
-- bufferRequestWithUserInput : Signal UserInput
-- bufferRequestWithUserInput = Signal.sampleOn requestBuffer userInputSignal



-- sampleOn : Signal a -> Signal b -> Signal b


-- let's juoin


-- I'm not actually sure how to handle triggers


-- we can use map to merge different signals into one (using a record)
-- we also have a signal True from requestBuffer, which is really just a pulse (we don't care about the value)





-- bufferStateSignal : Signal BufferState
-- bufferStateSignal = Signal.foldp updateBufferState initialBufferState bufferRequestWithUserInput


{- getSampleTime : Int -> Float -> Float
getSampleTime bufferIndex bufferStartTime =
    let
        _ = Debug.log "bufferIndex" bufferStartTime

    in
        bufferStartTime + (toFloat bufferIndex * sampleDuration) -}









-- incoming port (no longer used)
-- port requestBuffer : Signal Bool



-- main =
--   text "Hello, World!"
