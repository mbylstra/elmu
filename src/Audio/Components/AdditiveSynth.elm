module Audio.Components.AdditiveSynth where

import Audio.MainTypes exposing (..)
import Audio.Atoms.Add exposing (namedAdd)
import Audio.Atoms.Sine exposing (sine, sineDefaults)


additiveSynthAudioGraph : Float -> Float -> ListGraph
additiveSynthAudioGraph fundamentalFrequency numOscillators =
    let
        getId n =
            "harmonic" ++ toString n
        getSinNode n =
            let
                frequency = n * fundamentalFrequency
                id = getId n
            in
                sine  { sineDefaults | id = id, frequency = Value frequency}

        oscs = List.map getSinNode [1..numOscillators]
        mixerInputs = List.map (\n -> ID (getId n)) [1..numOscillators]

    in
        oscs ++ [namedAdd "additiveSynth" mixerInputs]
