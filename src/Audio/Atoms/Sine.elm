module Audio.Atoms.Sine where

import Array exposing (Array)
import Basics

import Audio.MainTypes exposing (..)
import Audio.AudioNodeFunctions exposing (getPeriodSeconds, sampleDuration, fmod)


sinLookupFrequency : Float
sinLookupFrequency = 20.0

sinLookupDuration : Float
sinLookupDuration = 1.0 / sinLookupFrequency

sinLookupArrayLength: Int
sinLookupArrayLength = floor (sinLookupDuration / sampleDuration)

sinLookup : Array Float
sinLookup =
    let
        getSample n =
            let
                phase = toFloat n / toFloat sinLookupArrayLength
            in
                Basics.sin (phase * 2.0 * pi)
    in
        Array.initialize sinLookupArrayLength getSample


sinWave : Float -> Float -> Float -> Float -> (Float, Float)
sinWave frequency frequencyOffset phaseOffset prevPhase =
    -- currently ignore frequencyOffset
    let
        phaseOffset = phaseOffset / 2.0
        periodSeconds = getPeriodSeconds (frequency + frequencyOffset)
        phaseIncrement = sampleDuration / periodSeconds
        currPhase = prevPhase + phaseIncrement
        outputPhase = currPhase + phaseOffset
        outputPhaseNormed = fmod outputPhase 1.0
        lookupArrayIndex = floor (outputPhaseNormed * toFloat sinLookupArrayLength)
        amplitude =
            case Array.get lookupArrayIndex sinLookup of
                Just amplitude' -> amplitude'
                Nothing -> Debug.crash("arraylookup out of index")
    in
        (amplitude, currPhase)  -- I actually think returning a tuple is problematic for performance! You want to stick to as basic as possible data types.

type alias Args =
  { id : String
  , frequency: Input
  , frequencyOffset: Input
  , phaseOffset: Input
  }

sine : Args -> AudioNode
sine {frequency, frequencyOffset, phaseOffset} =
  Oscillator
    { id = ""
    , func = sinWave
    , inputs = { frequency = frequency, frequencyOffset = frequencyOffset, phaseOffset = phaseOffset }
    , state =
        { outputValue = 0.0, phase = 0.0  }
    }


sineDefaults : Args
sineDefaults =
  { id = ""
  , frequency = Value 440.0
  , frequencyOffset = Value 0.0
  , phaseOffset = Value 0.0
  }
