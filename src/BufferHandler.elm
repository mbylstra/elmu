module BufferHandler where


import Gui exposing(getFrequency, bufferSize) -- this is pretty wierd, but the native stuff doesn't work unless you import at least something from the main module
-- import Gui

import Lib.MutableArray as MutableArray exposing (MutableArray)
import Lib.StringKeyMutableDict as StringKeyMutableDict exposing (StringKeyMutableDict)

import Audio.StatePool as StatePool exposing (StatePool)

-- import Dict exposing (Dict)
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
    , statePool: StatePool
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
  , graph = StringKeyMutableDict.empty ()
  , buffer = MutableArray.repeat bufferSize 0.0
  , bufferIndex = 0
  , statePool = StringKeyMutableDict.empty ()
  }



-- type alias Asdf (Positioned {})
-- reallyDumb : String
-- reallyDumb = dummy

-- initialBuffer : Array Float
-- initialBuffer = Array.repeat bufferSize 0.0


sampleRate : Float
sampleRate = 44100.0

sampleDuration : Float
sampleDuration = 1.0 / sampleRate

{- a helper function -}
foldn : (a -> a) -> a -> Int -> a
foldn func initial count =
  let
    -- _ = Debug.log "func" func
    -- _ = Debug.log "initial" initial
    -- _ = Debug.log "count" count
    _ = 0

  in
    if
        count > 0
    then
        foldn func (func initial) (count - 1)
    else
        initial


-- let's just hardcode sample rate for now (it's easier!)


updateForSample : ui -> BufferState ui -> BufferState ui
updateForSample uiModel bufferState =
  let
      -- _ = Debug.crash "updateForSample"
      newTime  = bufferState.time + sampleDuration
      newBufferIndex = bufferState.bufferIndex + 1
      -- _ = Debug.log "uiModel" uiModel
      -- _ = Debug.log "time" time
  in
    let
      value = updateGraph uiModel bufferState.statePool bufferState.graph
      -- (value, newGraph) = (0.0, graph)
      -- _ = Debug.crash "updateForSample"
      _ = MutableArray.set newBufferIndex value bufferState.buffer
    in
      { bufferState |
        time  = newTime
      , bufferIndex = newBufferIndex
      }


updateBufferState : ui -> BufferState ui -> BufferState ui
updateBufferState uiModel prevBufferState =
  let
    -- _ = Debug.log "prevBufferState" prevBufferState
    -- _ = Debug.log "uiModel" uiModel
    time = prevBufferState.time + sampleDuration
    -- _ = Debug.log "time" time

    initialBufferState =
      { prevBufferState | time = time, bufferIndex = 0 }

    -- _ = Debug.log "initialBufferState" initialBufferState
    -- _ = Debug.log "bufferSize" bufferSize

  in
    foldn (updateForSample uiModel) initialBufferState bufferSize
