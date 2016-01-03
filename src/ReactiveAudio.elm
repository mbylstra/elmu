module ReactiveAudio where

import Html exposing (text)

import Gui exposing(dummy)



-- import Debug exposing (log)

-- import Signal
-- import StartApp.Simple as StartApp

-- import Html exposing (text)
-- import Graphics.Element
-- import Graphics.Input

-- import Time exposing (Time, fps)
-- import Keyboard
import AudioNodes exposing

    ( squareWave
    , OscillatorType(Square, Saw, Sin)
    , oscillator
    , simpleLowPassFilter
    , sinWave
    )

-- import Gui exposing (UserInput)

import Array exposing(Array)

import Orchestrator exposing
    ( DictGraph
    , ListGraph
    , toDict
    , AudioNode(Oscillator, Destination, Add, FeedforwardProcessor, Gain)
    , Input(ID, Default, Value)
    , updateGraph
    , ExternalState
    , ExternalInputState
    )

--------------------------------------------------------------------------------
-- Types
--------------------------------------------------------------------------------

-- type GuiAction : AudioOn Bool
-- type Input = ID String | Value Float | Default   -- or it could be an AudioNode! Maybe?

type alias Buffer = Array Float

type alias ExternalInputState =
    { xWindowFraction: Float
    , yWindowFraction: Float
    , audioOn : Bool
    }

type alias BufferState =
    { time: Float
    , graph: DictGraph
    , buffer: Buffer
    , bufferIndex: Int
    , externalInputState: ExternalInputState
    }


reallyDumb : String
reallyDumb = dummy


{- a helper function -}
foldn : (a -> a) -> a -> Int -> a
foldn func initial count =
    if
        count > 0
    then
        foldn func (func initial) (count - 1)
    else
        initial


destinationA : AudioNode
destinationA =
    Destination
        { id = "destinationA"
        , input = ID "squareA"
        , state =
            { outputValue = 0.0 }
        }


sinNode : String -> {frequency: Input, frequencyOffset: Input, phaseOffset: Input} -> AudioNode
sinNode id {frequency, frequencyOffset, phaseOffset} =
  Oscillator
    { id = id
    , function = sinWave
    , inputs = { frequency = frequency, frequencyOffset = frequencyOffset, phaseOffset = phaseOffset }
    , state =
        { outputValue = 0.0, phase = 0.0  }
    }

squareNode : String -> {frequency: Input, frequencyOffset: Input, phaseOffset: Input} -> AudioNode
squareNode id {frequency, frequencyOffset, phaseOffset} =
  Oscillator
    { id = id
    , function = squareWave
    , inputs = { frequency = frequency, frequencyOffset = frequencyOffset, phaseOffset = phaseOffset }
    , state =
        { outputValue = 0.0, phase = 0.0  }
    }

gainNode : String -> {signal: Input, gain: Input} -> AudioNode
gainNode id {signal, gain} =
    Gain
        { id = id
        , function = AudioNodes.gain
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



additiveSynthAudioGraph baseFrequency numOscillators =
    let
        getId n =
            "harmonic" ++ toString n
        getSinNode n =
            let
                frequency = n * baseFrequency
                id = getId n
            in
                squareNode id {frequency = Value frequency, frequencyOffset = Default, phaseOffset = Default}


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


audioGraph =
    (additiveSynthAudioGraph 100.0 6)
    ++ [ destinationNode {signal = ID "additiveSynth"} ]


main =
  text "Hello, World!"
