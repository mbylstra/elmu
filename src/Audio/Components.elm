module Audio.Components where

import Audio.MainTypes exposing (..)
import Audio.AudioNodes exposing (..)


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
                sinNode id {frequency = Value frequency, frequencyOffset = Default, phaseOffset = Default}
                -- dummyNode id {frequency = Value frequency, frequencyOffset = Default, phaseOffset = Default}


        oscs = List.map getSinNode [1..numOscillators]
        mixerInputs = List.map (\n -> ID (getId n)) [1..numOscillators]

    in
        oscs ++ [adderNode "additiveSynth" mixerInputs]



type alias ModulatorNodeSpec =
  { id : String
  , multiple : Float
  , detune : Input
  , modulator : Input
  , level : Input
  }

type alias FMSynthSpec =
  { frequency: Float
  , modulator: Input
  , modulatorNodes: List ModulatorNodeSpec
  }

-- NOTE: I think this is currently really dumb and doesn't respond
-- to pitch

fmSynth : String -> FMSynthSpec -> List AudioNode
fmSynth id {frequency, modulator, modulatorNodes} =
    let
        carrierNode = sinNode id
            { frequency = Value frequency
            , frequencyOffset = Default
            , phaseOffset = modulator
            }

        createModulatorNodes : Float -> ModulatorNodeSpec -> List AudioNode
        createModulatorNodes fundamentalFrequency spec =
          [ sinNode spec.id
                { frequency = Value (frequency * spec.multiple)
                , frequencyOffset = Default
                , phaseOffset = spec.modulator
                }
          , gainNode (spec.id ++ ".gain") {signal = ID spec.id, gain = spec.level} --to do hook up to actual gain input
          ]
    in
        [carrierNode] ++ List.concatMap (createModulatorNodes frequency) modulatorNodes
