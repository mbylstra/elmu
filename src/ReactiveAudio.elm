module ReactiveAudio where

import Gui exposing(dummy) -- this is pretty wierd, but the native stuff doesn't work unless you import at least something from the main module


import Audio.AudioNodes exposing(..)
import Audio.MainTypes exposing(..)
import Audio.Components.FmSynth exposing(..)
import Audio.Components.AdditiveSynth exposing(..)
import Audio.Atoms.Sine exposing (sine, sineDefaults)
import Audio.Atoms.Add exposing (add)

-- This is necessary so that The Gui code is linked so we can expose it. I have no idea why.
reallyDumb : String
reallyDumb = dummy

fmSynth1 : ListGraph
fmSynth1 = fmSynth "fm"
  { frequency = GUI "frequency"   -- stlil unable to respond to frequency GUI "frequency"
  , modulator = ID "fm.1"
  , modulatorNodes =
    [ { id = "fm.1"
      , multiple = 1.0
      -- , detune = Default
      , detune = Default
      , modulator = ID "fm.2.gain" -- we must put .gain in until we can chain nodes into one
      , level = GUI "knobs.attack"
      }
    , { id = "fm.2"
      , multiple = 1.0
      , detune = Default
      , modulator = ID "fm.3.gain"  -- we need a better type than Defaualt for "No input connected"
      , level = GUI "knobs.decay"
      }
    , { id = "fm.3"
      , multiple = 4.0
      , detune = Default
      , modulator = Default  -- we need a better type than Defaualt for "No input connected"
      , level = GUI "knobs.sustain"
      }
    -- this is what feedback would look like
    -- , { mid = "2"
    --     multiple = Value 1.0
    --     detune = Default
    --     modulator : Self -- union type: Carrier | Self | MID String | NodeID  --- modulate with ANYTHING outside the graph
    --   }
    ]
  }


audioGraph3 : ListGraph
audioGraph3 =
    (additiveSynthAudioGraph {fundamentalFrequency=100.0, numOscillators=30}) -- this is where we pass input, not value
    ++ [ destinationNode <| ID "additiveSynth" ]

fmSynthGraph : ListGraph
fmSynthGraph =
  fmSynth1
    ++ [ destinationNode <| ID "fm" ]

theremin : ListGraph
theremin =
  -- [ sinNode "a" {frequency = GUI "frequency", frequencyOffset = Default, phaseOffset = Default}
  -- , sinNode "b" {frequency = GUI "frequency", frequencyOffset = Default, phaseOffset = Default}
  -- [ sinNode "a" { Sin.d | frequency = GUI "frequency"}
  -- , sinNode "b" { Sin.d | frequency = GUI "frequency"}
  [ destinationNode <| Node <|
      add
        [ Node <| sine
            { sineDefaults
            | frequency = GUI "frequency"
            }
        , Node <| sine
            { sineDefaults
            | frequency = Node <| add [GUI "frequency", Value 81.0]
            }
        ]
  ]



-- inlineNodesExample : ListGraph

-- this is the equivalent to the main function
-- should we perhaps combine the two into one module?? (you can always split them in two yourself)
-- the biggest annoyance is having to name this ReactiveAudio.elm by convention.
audioGraph : ListGraph
audioGraph = theremin
-- audioGraph = fmSynthGraph
