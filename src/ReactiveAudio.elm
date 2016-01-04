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
    , gainNode "mod1Frequency" {signal = ID "pitch", gain = Value 3.0}
    , sinNode "mod1" {frequency = Value 400.0, frequencyOffset = Default, phaseOffset = ID "mod2"}
    , sinNode "root1" {frequency = Value 200.0, frequencyOffset = Default, phaseOffset = ID "mod1"}
    , destinationNode {signal = ID "root1"}
    ]


audioGraph : ListGraph
audioGraph =
    (additiveSynthAudioGraph 100.0 30)
    ++ [ destinationNode {signal = ID "additiveSynth"} ]
