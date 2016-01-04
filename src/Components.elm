module Components where

import MainTypes exposing (..)
import AudioNodes exposing (..)

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
