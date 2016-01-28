module Audio.Components.FmSynth where

import Audio.MainTypes exposing (..)
import Audio.AudioNodes exposing (..)


type alias FMSynthSpec =
  { frequency: Input
  , modulator: Input
  , modulatorNodes: List ModulatorNodeSpec
  }

type alias ModulatorNodeSpec =
  { id : String
  , multiple : Float
  , detune : Input
  , modulator : Input
  , level : Input
  }


-- NOTE: I think this is currently really dumb and doesn't respond
-- to pitch

fmSynth : String -> FMSynthSpec -> List AudioNode
fmSynth id {frequency, modulator, modulatorNodes} =
    let
        carrierNode = sinNode id
            { frequency = frequency
            , frequencyOffset = Default
            , phaseOffset = modulator
            }

        createModulatorNodes : Input -> ModulatorNodeSpec -> List AudioNode
        createModulatorNodes fundamentalFrequency spec =
          [ sinNode spec.id
                -- { frequency = Value (frequency * spec.multiple) -- hmm, this is where it gets annoying
                -- We either need to create an adder node (annoying, but let's do for now), or we need to make it
                -- possible to nest nodes that aren't reused.
                { frequency = frequency
                , frequencyOffset = Default
                , phaseOffset = spec.modulator
                }
          , gainNode (spec.id ++ ".gain") {signal = ID spec.id, gain = spec.level} --to do hook up to actual gain input
          ]
    in
        [carrierNode] ++ List.concatMap (createModulatorNodes frequency) modulatorNodes
