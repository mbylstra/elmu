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

sinNode : String -> {frequency: Input, frequencyOffset: Input, phaseOffset: Input} -> AudioNode
sinNode id {frequency, frequencyOffset, phaseOffset} =
  Oscillator
    { id = id
    , func = sinWave
    , inputs = { frequency = frequency, frequencyOffset = frequencyOffset, phaseOffset = phaseOffset }
    , state =
        { outputValue = 0.0, phase = 0.0  }
    }

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
adderNode : String -> List Input -> AudioNode
adderNode id inputs =
    Add
        { id = id
        , inputs = inputs
        , state =
            { outputValue = 0.0 }
        }

destinationNode : {signal: Input} -> AudioNode
destinationNode {signal} =
    Destination
        { id = "destination"
        , input = signal
        , state =
            { outputValue = 0.0 }
        }

commaHelper : AudioNode
commaHelper =
  sinNode "dummy123456789" {frequency = Default, frequencyOffset = Default, phaseOffset = Default }
