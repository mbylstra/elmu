module ReactiveAudio where

-- import Debug exposing (log)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (on, targetChecked)
-- import Signal
-- import StartApp.Simple as StartApp

-- import Html exposing (text)
-- import Graphics.Element
-- import Graphics.Input

import Time exposing (Time, fps)
-- import Keyboard
import Mouse
import Window
import AudioNodes exposing

    ( squareWave
    , OscillatorType(Square, Saw, Sin)
    , oscillator
    , simpleLowPassFilter
    , sinWave
    )

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
type GuiAction = AudioOn Bool

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






type alias UserInput =
    { mousePosition : { x : Int, y : Int}
    , windowDimensions : { width: Int, height: Int}
    , audioOn : Bool
    }

{- type alias Positioned a =
    { a | x : Float, y : Float } -}


{- type alias EmptyRecord a =
    { a |  x : Float} -}
{- type alias Positioned a =
    { a | x : Float, y : Float } -}


{- type alias EmptyRecord a =
    { a |  x : Float} -}


-- type alias Asdf (Positioned {})

initialBuffer : Array Float
initialBuffer = Array.repeat bufferSize 0.0


{- a helper function -}
foldn : (a -> a) -> a -> Int -> a
foldn func initial count =
    if
        count > 0
    then
        foldn func (func initial) (count - 1)
    else
        initial


-- let's just hardcode sample rate for now (it's easier!)

port requestBuffer : Signal Bool


everySecond : Signal Time
everySecond = fps 1

bufferSize : Int
bufferSize = 4096

sampleRate : Int
sampleRate = 44100

sampleDuration : Float
sampleDuration = 1.0 / toFloat sampleRate



updateBufferState : UserInput -> BufferState -> BufferState
updateBufferState userInput prevBufferState =

    let

        externalInputState : ExternalInputState
        externalInputState =
            { xWindowFraction = toFloat userInput.mousePosition.x / toFloat userInput.windowDimensions.width
            , yWindowFraction = toFloat userInput.mousePosition.y / toFloat userInput.windowDimensions.height
            , audioOn = userInput.audioOn
            }
        -- _ = Debug.log "externalInputState: " externalInputState

        time = prevBufferState.time + sampleDuration

        -- frequency = 40.0 + (xWindowFraction * 10000.0) -- how do we pass this in?

        initialGraph = prevBufferState.graph
{-         _ = Debug.log "sampleCuration" sampleDuration
        _ = Debug.log "updateBufferState time" time -}


        -- surely we can do this without having to manually create a counter?
        -- we can just iterate over the last buffer, and ignore values

        prevBuffer = prevBufferState.buffer

        initialBufferState : BufferState
        initialBufferState =
            { time = time
            , graph = initialGraph
            , buffer = prevBuffer
            , bufferIndex = 0
            , externalInputState = externalInputState
            }

        updateForSample {time, graph, buffer, bufferIndex} =
            let
                newTime  = time + sampleDuration
                externalState =
                    { time = newTime
                    , externalInputState = externalInputState
                    }
--                 _ = Debug.log "udpateForSample newTime" newTime
                newBufferIndex = bufferIndex + 1
--                 _ = Debug.log "newBufferIndex" newBufferIndex
--                 _ = Debug.log "value" value
            in
                if
                    externalInputState.audioOn == True
                then
                    let
                        (newGraph, value) = updateGraph graph externalState
                    in
                        { time  = newTime
                        , graph = newGraph
                        , buffer = Array.set newBufferIndex value buffer
                        , bufferIndex = newBufferIndex
                        , externalInputState =  externalInputState
                        }
                else
                    { time  = newTime
                    , graph = graph
                    , buffer = Array.set newBufferIndex 0.0 buffer
                    , bufferIndex = newBufferIndex
                    , externalInputState =  externalInputState
                    }
    in
        foldn updateForSample initialBufferState bufferSize


{- squareA =
    Generator
        { id = "squareA"
        , function = oscillator Square 444.0
        , state =
            { outputValue = 0.0  }
        } -}



destinationA : AudioNode
destinationA =
    Destination
        { id = "destinationA"
        , input = ID "squareA"
        , state =
            { outputValue = 0.0 }
        }

{- makeSquare id frequency =
    Generator
        { id = id
        , function = oscillator Saw frequency
        , state =
            { outputValue = 0.0  }
        } -}

{- makeSin id frequency =
    Generator
        { id = id
        , function = oscillator Sin frequency
        , state =
            { outputValue = 0.0  }
        } -}




{- lowPassNode id inputName =
    FeedforwardProcessor
        { id = id
        , input = ID inputName
        , function = simpleLowPassFilter
        , state =
            { outputValue = 0.0
--             , prevValues = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
            , prevValues =  List.repeat 2 0.0
--             , prevValues = [0.0, 0.0, 0,0]
            }
        } -}

sinNode : String -> {frequency: Input, frequencyOffset: Input, phaseOffset: Input} -> AudioNode
sinNode id {frequency, frequencyOffset, phaseOffset} =
  Oscillator
    { id = id
    , function = sinWave
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






testGraph : ListGraph
testGraph =
    [ commaHelper

{-     , sinNode "mod3'" {frequency = Value 200.0, frequencyOffset = Default, phaseOffset = Default}
    , gainNode "mod3" {signal = ID "mod3'", gain = Value 70.0}

    , sinNode "mod2'" {frequency = Value 800.0, frequencyOffset = ID "mod3" , phaseOffset = Default}
    , gainNode "mod2" {signal = ID "mod2'", gain = Value 5000.0}

    , sinNode "mod1'" {frequency = Value 400.0, frequencyOffset = ID "mod2", phaseOffset = Default}
    , gainNode "mod1" {signal = ID "mod1'", gain = Value 200.0} -}

{-     , sinNode "mod3'" {frequency = Value 200.0, frequencyOffset = Default, phaseOffset = Default}
    , gainNode "mod3" {signal = ID "mod3'", gain = Value 70.0}

    , sinNode "mod2'" {frequency = Value 800.0, frequencyOffset = ID "mod3" , phaseOffset = Default}
    , gainNode "mod2" {signal = ID "mod2'", gain = Value 5000.0} -}

{-     , sinNode "mod1" {frequency = Value 11025.0, frequencyOffset = Default, phaseOffset = Default}
--     , gainNode "mod1" {signal = ID "mod1'", gain = Value 200.0}
    , sinNode "root1" {frequency = Value 11025.0, frequencyOffset = Default, phaseOffset = ID "mod1"} -}

--     , sinNode "mod2" {frequency = Value 345.0, frequencyOffset = Default, phaseOffset = Default}
{-     , sinNode "mod1" {frequency = Value 11025.0, frequencyOffset = Value 666.0, phaseOffset = Default}
    , sinNode "root1" {frequency = Value 11025.0, frequencyOffset = Default, phaseOffset = ID "mod1"} -}
--     , sinNode "root1" {frequency = Value 440.0, frequencyOffset = Default, phaseOffset = Default}

{-     , sinNode "mod6" {frequency = Value 200.0, frequencyOffset = Value 666.0, phaseOffset = Default}
    , sinNode "mod5" {frequency = Value 200.0, frequencyOffset = Value 666.0, phaseOffset = ID "mod6"}
    , sinNode "mod4" {frequency = Value 200.0, frequencyOffset = Value 666.0, phaseOffset = ID "mod5"} -}

    -- , sinNode "lfoRaw" {frequency = Value 0.25, frequencyOffset = Default, phaseOffset = Default}
    -- , gainNode "lfoGain" {signal = ID "lfoRaw", gain = Value 20.0}
    -- , adderNode "pitch" [Value 200.0, ID "lfoGain"]

--     , sinNode "mod3" {frequency = ID "pitch", frequencyOffset = Default, phaseOffset = Default}
--     , sinNode "mod2" {frequency = ID "pitch", frequencyOffset = Default, phaseOffset = Default}

    -- , gainNode "mod1Frequency" {signal = ID "pitch", gain = Value 3.0}
    -- , sinNode "mod1" {frequency = ID "mod1Frequency", frequencyOffset = Default, phaseOffset = Default }

--     , sinNode "root1" {frequency = ID "pitch", frequencyOffset = Default, phaseOffset = ID "mod1"}
    -- , sinNode "root1" {frequency = ID "mod1Frequency", frequencyOffset = Default, phaseOffset = Default}
    -- , sinNode "root1" {frequency = ID "pitch", frequencyOffset = Default, phaseOffset = Default}
    , sinNode "root1" {frequency = Value 200.0, frequencyOffset = Default, phaseOffset = Default}


    , destinationNode {signal = ID "root1"}
--     , destinationNode {signal = ID "lfoRaw"}

    ]





-- perhaps put external input here? Why not
testGraphDict : DictGraph
testGraphDict = toDict testGraph



initialBufferState : BufferState
initialBufferState =
    { time = 0.0
    , graph = testGraphDict
    , buffer = initialBuffer
    , bufferIndex = 0
    , externalInputState =
        { xWindowFraction = 0.0
        , yWindowFraction = 0.0
        , audioOn = False
        }
    }





-- I think we need to merge requestBuffer and everySecond

-- map2 means we can mix bufferSignal and mouse signals and combine them into
-- a new type (a record with both), but this function is updated whenever *either* change

-- let's combine wasd and mousePosition into a signal as a demo


-- wasd : Signal { x : Int, y : Int }

userInputSignal : Signal UserInput
userInputSignal =
    Signal.map3
        ( \(mouseX, mouseY) (windowWidth, windowHeight) audioOn ->
            -- { wasd = wasd
            { mousePosition = {x = mouseX, y = mouseY}
            , windowDimensions = {width = windowWidth, height = windowHeight}
            , audioOn = audioOn
            }
        )
        -- Keyboard.wasd
        Mouse.position
        Window.dimensions
        guiModelSignal



bufferRequestWithUserInput : Signal UserInput
bufferRequestWithUserInput = Signal.sampleOn requestBuffer userInputSignal



-- sampleOn : Signal a -> Signal b -> Signal b


-- let's juoin


-- I'm not actually sure how to handle triggers


-- we can use map to merge different signals into one (using a record)
-- we also have a signal True from requestBuffer, which is really just a pulse (we don't care about the value)





bufferStateSignal : Signal BufferState
bufferStateSignal = Signal.foldp updateBufferState initialBufferState bufferRequestWithUserInput


{- getSampleTime : Int -> Float -> Float
getSampleTime bufferIndex bufferStartTime =
    let
        _ = Debug.log "bufferIndex" bufferStartTime

    in
        bufferStartTime + (toFloat bufferIndex * sampleDuration) -}





audioOnCheckbox : Signal.Address GuiAction -> Bool -> Html
audioOnCheckbox address isChecked =
  div []
      [ input
          [ type' "checkbox"
          , checked isChecked
          , on "change" targetChecked (\isChecked -> Signal.message address (AudioOn isChecked))
          ]
          []
      , text "AUDIO ON"
      , text (if isChecked then " (ON)" else " (OFF)")
      ]


updateGuiModel : GuiAction -> Bool -> Bool
updateGuiModel action b =
    case action of
        AudioOn bool ->
            bool

guiMailbox : Signal.Mailbox GuiAction
guiMailbox = Signal.mailbox (AudioOn True)

guiModelSignal : Signal Bool
guiModelSignal =
    Signal.foldp
        updateGuiModel
        False
        guiMailbox.signal

guiView : Bool -> Html
guiView model =
    audioOnCheckbox guiMailbox.address model
guiSignal : Signal Html
guiSignal = Signal.map guiView guiModelSignal

-- map : (a -> result) -> Signal a -> Signal result

-- foldp
--     :  (a -> state -> state)
--     -> state
--     -> Signal a
--     -> Signal state

-- main : Html
-- main =
--     audioOnCheckbox

main : Signal Html
main = guiSignal


port latestBuffer : Signal (Array Float)
port latestBuffer = Signal.map .buffer bufferStateSignal
