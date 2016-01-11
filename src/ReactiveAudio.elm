module ReactiveAudio where
import Gui exposing(dummy)


import AudioNodes exposing(..)
import MainTypes exposing(..)
import Components exposing(..)

-- This is necessary so that The Gui code is linked so we can expose it. I have no idea why.
reallyDumb : String
reallyDumb = dummy

audioGraph2: ListGraph
audioGraph2 =
    [ commaHelper
    , sinNode "mod3" {frequency = Value 800.0, frequencyOffset = Default, phaseOffset = Default}
    , sinNode "mod2" {frequency = Value 600.0, frequencyOffset = Default, phaseOffset = ID "mod3"}
    -- , gainNode "mod1Frequency" {signal = ID "pitch", gain = Value 3.0}
    , sinNode "mod1" {frequency = Value 400.0, frequencyOffset = Default, phaseOffset = ID "mod2"}
    , sinNode "root1" {frequency = Value 200.0, frequencyOffset = Default, phaseOffset = ID "mod1"}
    , destinationNode {signal = ID "root1"}
    ]



fmSynth1 : ListGraph
fmSynth1 = fmSynth "fm"
  { frequency = 200.0
  , modulator = ID "fm.1"
  , modulatorNodes =
    [ { id = "fm.1"
      , multiple = 1.0
      , detune = Default
      , modulator = ID "fm.2"
      }
    , { id = "fm.2"
      , multiple = 1.0
      , detune = Default
      , modulator = ID "fm.3"  -- we need a better type than Defaualt for "No input connected"
      }
    , { id = "fm.3"
      , multiple = 4.0
      , detune = Default
      , modulator = Default  -- we need a better type than Defaualt for "No input connected"
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
    (additiveSynthAudioGraph 100.0 30)
    ++ [ destinationNode {signal = ID "additiveSynth"} ]

fmSynthGraph : ListGraph
fmSynthGraph =
  fmSynth1
    ++ [ destinationNode {signal = ID "fm"} ]

theremin =
  -- [ sinNode "t" {frequency = GUI "pitch", frequencyOffset = Default, phaseOffset = Default}
  -- [ sinNode "t" {frequency = GUI "keyboardFrequency", frequencyOffset = Default, phaseOffset = Default}
  [ sinNode "t" {frequency = GUI "guiFrequency", frequencyOffset = Default, phaseOffset = Default}
  , destinationNode {signal = ID "t"}
  ]

audioGraph : ListGraph
audioGraph = theremin
