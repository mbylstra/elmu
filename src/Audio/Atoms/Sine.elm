module Audio.Atoms.Sine where

import Array exposing (Array)
import Basics
import ElmTest exposing (..)
import Dict exposing(Dict)

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

type alias Args uiModel =
  { id : Maybe String
  , frequency: Input uiModel
  , frequencyOffset: Input uiModel
  , phaseOffset: Input uiModel
  }


sine : (Args uiModel) -> (AudioNode uiModel)
sine args =
  Oscillator
    { userId = args.id
    , autoId = Nothing
    , func = sinWave
    , inputs = Dict.fromList
      [ ("frequency", args.frequency)
      , ("frequencyOffset", args.frequencyOffset)
      , ("phaseOffset", args.phaseOffset)
      ]
    , outputValue = 0.0
    , phase = 0.0
    }


-- This is pretty Annoying, but it seems we must force the user
-- to provide a union type for Nothing, or wrap it in a maybe?
-- Lets worry about maybe later. It will be annoying to have to wrap
-- a node with `Just` whe providing an id, but still, feedback is the rarer use case.
-- Things might get interesting if we want to display audio model data in the UI :/

sineDefaults : Args uiModel
sineDefaults =
  { id = Nothing
  , frequency = Value 440.0
  , frequencyOffset = Value 0.0
  , phaseOffset = Value 0.0
  }

tests : Test
tests =
    suite "sineWave"
        [
          test "sineWave"
            (assertEqual
                (0.0, 0.0)
                (sinWave 11025.0 0.0 0.0 0.0)
            )
        , test "sinLookup"
            (assertEqual
                (Array.fromList([0.0]))
                (sinLookup)
            )
        ]
