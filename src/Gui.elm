module Gui where

import Mouse
import Window
import Keyboard
import Char exposing (KeyCode, fromCode)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (on, targetChecked)
import Piano exposing (piano, pianoSignal)
import Slider exposing (slider)

import Maybe exposing (withDefault)



type alias UserInput =
  { mousePosition : { x : Int, y : Int}
  , mouseWindowFraction : { x : Float, y : Float}
  , windowDimensions : { width: Int, height: Int}
  , guiFrequency : Float
  , windowMouseXPitch : Float
  , audioOn : Bool
  , slider1 : Float
  }

type alias GuiModel =
  { audioOn : Bool
  , slider1: Float
  }

initialUserInput : UserInput
initialUserInput =
  { mousePosition = { x = 0, y = 0}
  , mouseWindowFraction = { x = 0.0, y = 0.0}
  , windowDimensions = { width= 0, height= 0}
  , guiFrequency = 400.0
  , windowMouseXPitch = 200
  , audioOn = False
  , slider1 = 0.0
  }

type Action = AudioOn Bool | Slider1 Float

dummy : String
dummy = "dummy!"

type alias Pitch = Float

charToPitch : Char -> Maybe Pitch
charToPitch c =
  case c of
    's' -> Just 60.0
    'd' -> Just 62.0
    'f' -> Just 64.0

    'g' -> Just 65.0
    'h' -> Just 67.0
    'j' -> Just 69.0
    'k' -> Just 71.0

    'l' -> Just 72.0

    _ -> Nothing


-- pitchToFrequency  TODO!


pitchToFrequency : Float -> Float
pitchToFrequency pitch =
  2^((pitch - 49.0) / 12.0) * 440.0


updateGuiModel : Action -> GuiModel -> GuiModel
updateGuiModel action model =
  case action of
    AudioOn value ->
        { model | audioOn = value }
    Slider1 value ->
        { model | slider1 = value }

guiMailbox : Signal.Mailbox Action
guiMailbox = Signal.mailbox (AudioOn True)

initialModel : GuiModel
initialModel =
  { audioOn = True
  , slider1 = 0.0
  }

guiModelSignal : Signal GuiModel
guiModelSignal =
    Signal.foldp
        updateGuiModel
        initialModel
        guiMailbox.signal



audioOnCheckbox : Signal.Address Action -> Bool -> Html
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







guiView : GuiModel -> Html
guiView model =
    div []
        [ h1 [] [text "Elm Reactive Audio"]
        , div [class "synth"]
          [ audioOnCheckbox guiMailbox.address model.audioOn
          , slider (Signal.forwardTo guiMailbox.address Slider1)
          , piano 4 12.0
          ]
        ]

guiSignal : Signal Html
guiSignal = Signal.map guiView guiModelSignal

mouseWindowFraction' : (Int, Int) -> (Int, Int) -> { x : Float, y : Float}
mouseWindowFraction' (mouseX, mouseY) (windowWidth, windowHeight) =
  { x = toFloat mouseX / toFloat windowWidth
  , y = toFloat (windowHeight - mouseY) / toFloat windowHeight
  }

-- keyboardFrequency =

keyboardGuiPitch : Signal Float
keyboardGuiPitch =
  Signal.map (\keyCode -> keyCode |> fromCode |> charToPitch |> withDefault 0.0) Keyboard.presses

keyboardGuiFrequency : Signal Float
keyboardGuiFrequency =
  Signal.map pitchToFrequency keyboardGuiPitch

pianoGuiFrequency : Signal Float
pianoGuiFrequency =
  Signal.map pitchToFrequency pianoSignal

guiFrequency : Signal Float
guiFrequency =
  Signal.merge keyboardGuiFrequency pianoGuiFrequency

userInputSignal : Signal UserInput
userInputSignal =
  Signal.map4
    (\(mouseX, mouseY) (windowWidth, windowHeight) guiFrequency guiModel ->
      let
        mouseWindowFraction'' = mouseWindowFraction' (mouseX, mouseY) (windowWidth, windowHeight)
      in
        { mousePosition = {x = mouseX, y = mouseY}
        , windowDimensions = { width = windowWidth, height = windowHeight}
        , mouseWindowFraction = mouseWindowFraction''
        , audioOn = guiModel.audioOn
        , slider1 = guiModel.slider1
        , windowMouseXPitch = (mouseWindowFraction''.x * 400.0) + 50.0
        , guiFrequency = guiFrequency
        }
    )
    Mouse.position
    Window.dimensions
    guiFrequency
    guiModelSignal

port outgoingUserInput : Signal UserInput
port outgoingUserInput = userInputSignal

main : Signal Html
main = guiSignal



-- var key_code = 65;
-- result should be
--
-- character = "a";
