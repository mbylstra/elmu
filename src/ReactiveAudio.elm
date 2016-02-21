module ReactiveAudio where

import Gui exposing (getFrequency, bufferSize) -- this is pretty wierd, but the native stuff doesn't work unless you import at least something from the main module
-- import Dict

-- import Audio.AudioNodes exposing(..)
import Audio.MainTypes exposing(..)
-- import Audio.Components.FmSynth exposing(..)
-- import Audio.Components.AdditiveSynth exposing(..)
import Audio.Atoms.Sine as Sine exposing (sine, sineDefaults)
import Audio.Atoms.Destination exposing (destination)
import Audio.FlattenGraph exposing (flattenGraph)
-- import Helpers exposing (toMutableDict)


import BufferHandler exposing (updateBufferState)
 -- we need to import this so that JS can see it!


-- import Audio.Atoms.Add exposing (add)

-- import Dict exposing (Dict)


-- import BufferHandler exposing (initialState)

-- initialState = initialState
-- let
--   _ = Debug.log "" initialState
-- in
--   1


-- fmSynth1 : ListGraph
-- fmSynth1 = fmSynth "fm"
--   { frequency = GUI Gui.Model Gui.getFrequency"   -- stlil unable to respond to frequency GUI "frequency"
--   , modulator = ID "fm.1"
--   , modulatorNodes =
--     [ { id = "fm.1"
--       , multiple = 1.0
--       -- , detune = Default
--       , detune = Default
--       , modulator = ID "fm.2.gain" -- we must put .gain in until we can chain nodes into one
--       , level = GUI "knobs.attack"
--       }
--     , { id = "fm.2"
--       , multiple = 1.0
--       , detune = Default
--       , modulator = ID "fm.3.gain"  -- we need a better type than Defaualt for "No input connected"
--       , level = GUI "knobs.decay"
--       }
--     , { id = "fm.3"
--       , multiple = 4.0
--       , detune = Default
--       , modulator = Default  -- we need a better type than Defaualt for "No input connected"
--       , level = GUI "knobs.sustain"
--       }
--     -- this is what feedback would look like
--     -- , { mid = "2"
--     --     multiple = Value 1.0
--     --     detune = Default
--     --     modulator : Self -- union type: Carrier | Self | MID String |  --- modulate with ANYTHING outside the graph
--     --   }
--     ]
--   }


-- audioGraph3 : ListGraph NodeID
-- audioGraph3 =
--     (additiveSynthAudioGraph {fundamentalFrequency= Value 100.0, numOscillators=30}) -- this is where we pass input, not value
--     ++ [ destinationNode <| ID "additiveSynth" ]

-- fmSynthGraph : ListGraph
-- fmSynthGraph =
--   fmSynth1
--     ++ [ destinationNode <| ID "fm" ]

-- theremin : ListGraph NodeID
-- theremin =
--   -- [ sinNode "a" {frequency = GUI "frequency", frequencyOffset = Default, phaseOffset = Default}
--   -- , sinNode "b" {frequency = GUI "frequency", frequencyOffset = Default, phaseOffset = Default}
--   -- [ sinNode "a" { Sin.d | frequency = GUI "frequency"}
--   -- , sinNode "b" { Sin.d | frequency = GUI "frequency"}
--   [ destinationNode <| Node <|
--       add
--         [ Node <| sine
--             { sineDefaults
--             -- | frequency = GUI "frequency"
--             | frequency = Value 400.0
--             }
--         , Node <| sine
--             { sineDefaults
--             -- | frequency = Node <| add [GUI "frequency", Value 81.0]
--             | frequency = Node <| add [Value 20.0, Value 81.0]
--             }
--         ]
--   ]

-- type alias ListGraph id =  List (AudioNode (Maybe id))

-- type alias GuiModel = {a: Float}

-- getA guiModel = guiModel.a

-- guiModel = { a = 1.0}

-- basicGraph : ListGraph NodeID
-- basicGraph : List (AudioNode NodeID)
-- basicGraph : (List (AudioNode Gui.Model), AudioNode Gui.Model)
basicGraph : AudioNodes Gui.Model
basicGraph =
  [ sine
    { sineDefaults
    | id = Just "sin1"
    , frequency = Value 440.0
    -- , frequency = UI getFrequency
    }
  , destination "sin1"
  ]

-- inlineNodesExample : ListGraph

-- this is the equivalent to the main function
-- should we perhaps combine the two into one module?? (you can always split them in two yourself)
-- the biggest annoyance is having to name this ReactiveAudio.elm by convention.
-- audioGraph : ListGraph
-- audioGraph = theremin

-- audioGraph = fmSynthGraph


audioGraph : DictGraph Gui.Model
audioGraph = flattenGraph basicGraph


--
--
-- audioGraph : DictGraph
-- (listNodes, destination') = basicGraph


-- audioGraph : DictGraph Gui.Model
-- audioGraph = toMutableDict listNodes
