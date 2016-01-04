module ReactiveAudio where
import Html exposing (text)
import Gui exposing(dummy)


import AudioNodes exposing(..)
import MainTypes exposing(..)

-- import Orchestrator exposing
--     ( DictGraph
--     , ListGraph
--     , toDict
--     , AudioNode(Oscillator, Destination, Add, FeedforwardProcessor, Gain)
--     , Input(ID, Default, Value)
--     , updateGraph
--     , ExternalState
--     , ExternalInputState
--     )

reallyDumb : String
reallyDumb = dummy


additiveSynthAudioGraph : Float -> Float -> ListGraph
additiveSynthAudioGraph baseFrequency numOscillators =
    let
        getId n =
            "harmonic" ++ toString n
        getSinNode n =
            let
                frequency = n * baseFrequency
                id = getId n
            in
                sinNode id {frequency = Value frequency, frequencyOffset = Default, phaseOffset = Default}
                -- dummyNode id {frequency = Value frequency, frequencyOffset = Default, phaseOffset = Default}


        oscs = List.map getSinNode [1..numOscillators]
        mixerInputs = List.map (\n -> ID (getId n)) [1..numOscillators]

    in
        oscs ++ [adderNode "additiveSynth" mixerInputs]


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


main =
  text "Hello, World!"
