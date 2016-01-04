
module Gui where

import Mouse
import Window

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (on, targetChecked)

type alias UserInput =
    { mousePosition : { x : Int, y : Int}
    , windowDimensions : { width: Int, height: Int}
    , audioOn : Bool
    }

type GuiAction = AudioOn Bool

dummy : String
dummy = "dummy!"

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

port outgoingUserInput : Signal UserInput
port outgoingUserInput = userInputSignal

main : Signal Html
main = guiSignal
