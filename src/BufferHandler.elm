module BufferHandler where


-- import Gui

import Lib.MutableArray as MutableArray exposing (MutableArray)

import Dict exposing (Dict)
import Orchestrator exposing (updateGraph)

import Audio.MainTypes exposing (..)
type alias Buffer = MutableArray Float



-- type alias ExternalInputState =
--     { xWindowFraction: Float
--     , yWindowFraction: Float
--     , audioOn : Bool
--     }

type alias BufferState ui =
    { time: Float
    , graph: DictGraph ui
    , buffer: Buffer
    , bufferIndex: Int
    -- , uiModel: EncodedModel
    }



-- How can we implement initialState, if the user supplies
-- the ui Model??

-- The UI would have to provide the initial state right????
--  Becuase there is no record update syntax,
-- Or, we can do the tuple thing.

-- How would this work??
-- JS calls updateBuffer, and passes the uiModel.
-- So, all this stuff needs a ui type variable.

initialState : BufferState ui
initialState =
  { time = 0.0
  , graph = Dict.fromList []
  , buffer = MutableArray.repeat bufferSize 0.0
  , bufferIndex = 0
  }



-- type alias Asdf (Positioned {})
-- reallyDumb : String
-- reallyDumb = dummy

-- initialBuffer : Array Float
-- initialBuffer = Array.repeat bufferSize 0.0


bufferSize : Int
bufferSize = 1024
-- bufferSize =

sampleRate : Float
sampleRate = 44100.0

sampleDuration : Float
sampleDuration = 1.0 / sampleRate

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


updateForSample : ui -> BufferState ui -> BufferState ui
updateForSample uiModel {time, graph, buffer, bufferIndex} =
  let
      newTime  = time + sampleDuration
      newBufferIndex = bufferIndex + 1
  in
    let
      (value, newGraph) = updateGraph uiModel graph
    in
      { time  = newTime
      , graph = newGraph
      , buffer = MutableArray.set newBufferIndex value buffer
      , bufferIndex = newBufferIndex
      }


updateBufferState : ui -> BufferState ui -> BufferState ui
updateBufferState uiModel prevBufferState =
  let
    time = prevBufferState.time + sampleDuration
    initialGraph = prevBufferState.graph
    prevBuffer = prevBufferState.buffer

    initialBufferState =
      { time = time
      , graph = initialGraph
      , buffer = prevBuffer
      , bufferIndex = 0
      }

  in
    foldn (updateForSample uiModel) initialBufferState bufferSize
