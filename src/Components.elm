module Components where

import MainTypes exposing (..)
import AudioNodes exposing (..)


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



-- type ModulatorInput = Carrier | MID String | Nothing | ExternalID String

type alias ModulatorNodeSpec =
  { id : String
  , multiple : Float
  , detune : Input
  , modulator : Input
  }

type alias FMSynthSpec =
  { frequency: Float
  , modulator: Input
  , modulatorNodes: List ModulatorNodeSpec
  }

fmSynth : String -> FMSynthSpec -> List AudioNode
fmSynth id {frequency, modulator, modulatorNodes} =
    let
        carrierNode = sinNode id
            { frequency = Value frequency
            , frequencyOffset = Default
            , phaseOffset = modulator
            }

        createModulatorNode : Float -> ModulatorNodeSpec -> AudioNode
        createModulatorNode fundamentalFrequency spec =
            sinNode spec.id
                { frequency = Value (frequency * spec.multiple)
                , frequencyOffset = Default
                , phaseOffset = spec.modulator
                }
    in
        [carrierNode] ++ List.map (createModulatorNode frequency) modulatorNodes
    -- let
    --     getId n =
    --         "harmonic" ++ toString n
    --     getSinNode n =
    --         let
    --             frequency = n * fundamentalFrequency
    --             id = getId n
    --         in
    --             sinNode id {frequency = Value frequency, frequencyOffset = Default, phaseOffset = Default}
                -- dummyNode id {frequency = Value frequency, frequencyOffset = Default, phaseOffset = Default}
