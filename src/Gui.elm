module Gui where

import Mouse
import Window
import Keyboard
import Char exposing (KeyCode, fromCode)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (on, targetChecked)

import Maybe exposing (withDefault)

type alias UserInput =
    { mousePosition : { x : Int, y : Int}
    , mouseWindowFraction : { x : Float, y : Float}
    , windowDimensions : { width: Int, height: Int}
    , keyboardFrequency : Float
    , windowMouseXPitch : Float
    , audioOn : Bool
    }

type GuiAction = AudioOn Bool

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




guiView : Bool -> Html
guiView model =
    audioOnCheckbox guiMailbox.address model
guiSignal : Signal Html
guiSignal = Signal.map guiView guiModelSignal

mouseWindowFraction' : (Int, Int) -> (Int, Int) -> { x : Float, y : Float}
mouseWindowFraction' (mouseX, mouseY) (windowWidth, windowHeight) =
  { x = toFloat mouseX / toFloat windowWidth
  , y = toFloat (windowHeight - mouseY) / toFloat windowHeight
  }

userInputSignal : Signal UserInput
userInputSignal =
  Signal.map4
    (\(mouseX, mouseY) (windowWidth, windowHeight) keyCode audioOn ->
      let
        mouseWindowFraction'' = mouseWindowFraction' (mouseX, mouseY) (windowWidth, windowHeight)
      in
        { mousePosition = {x = mouseX, y = mouseY}
        , windowDimensions = { width = windowWidth, height = windowHeight}
        , mouseWindowFraction = mouseWindowFraction''
        , audioOn = audioOn
        , windowMouseXPitch = (mouseWindowFraction''.x * 400.0) + 50.0
        , keyboardFrequency = keyCode |> fromCode |> charToPitch |> withDefault 60.0 |> pitchToFrequency
        }
    )
    Mouse.position
    Window.dimensions
    Keyboard.presses
    guiModelSignal

port outgoingUserInput : Signal UserInput
port outgoingUserInput = userInputSignal

main : Signal Html
main = guiSignal



-- var key_code = 65;
-- result should be
--
-- character = "a";
