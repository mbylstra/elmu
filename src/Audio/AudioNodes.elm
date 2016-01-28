module Audio.AudioNodes where

import Audio.MainTypes exposing(..)


import Audio.AudioNodeFunctions exposing
    ( squareWave
    , OscillatorType(Square, Saw, Sin)
    , oscillator
    , simpleLowPassFilter
    , sinWave
    , zeroWave
    , gain
    )

import Audio.Atoms.Sine exposing (sine, sineDefaults)


squareNode : String -> {frequency: Input, frequencyOffset: Input, phaseOffset: Input} -> AudioNode
squareNode id {frequency, frequencyOffset, phaseOffset} =
  Oscillator
    { id = id
    , func = squareWave
    , inputs = { frequency = frequency, frequencyOffset = frequencyOffset, phaseOffset = phaseOffset }
    , state =
        { outputValue = 0.0, phase = 0.0  }
    }


dummyNode : String -> {frequency: Input, frequencyOffset: Input, phaseOffset: Input} -> AudioNode
dummyNode id {frequency, frequencyOffset, phaseOffset} =
  Oscillator
    { id = id
    , func = zeroWave
    , inputs = { frequency = frequency, frequencyOffset = frequencyOffset, phaseOffset = phaseOffset }
    , state =
        { outputValue = 0.0, phase = 0.0  }
    }

gainNode : String -> {signal: Input, gain: Input} -> AudioNode
gainNode id {signal, gain} =
    Gain
        { id = id
        , func = Audio.AudioNodeFunctions.gain
        , inputs = { signal = signal, gain = gain }
        , state =
            { outputValue = 0.0 }
        }

destinationNode : Input -> AudioNode
destinationNode input =
    Destination
        { id = "destination"
        , input = input
        , state =
            { outputValue = 0.0 }
        }

commaHelper : AudioNode
commaHelper = sine sineDefaults
