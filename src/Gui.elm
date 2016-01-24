module Gui where

import Mouse
import Window
import Keyboard
import Char exposing (KeyCode, fromCode)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (on, targetChecked, onMouseUp)
import Piano exposing (piano, pianoSignal)
-- import Slider exposing (slider)
import Signal exposing (Address)
import Color exposing (Color)

import ColorExtra exposing (toCssRgb)

import Maybe exposing (withDefault)

import MouseExtra

import Effects

import MouseExtra
import KnobRegistry exposing (Action(GlobalMouseUp, MousePosition))
import HtmlAttributesExtra exposing (..)



type alias UserInput =
  { mousePosition : { x : Int, y : Int}
  , mouseWindowFraction : { x : Float, y : Float}
  , windowDimensions : { width: Int, height: Int}
  , guiFrequency : Float
  , windowMouseXPitch : Float
  , audioOn : Bool
  , slider1 : Float
  }


type alias ColorScheme =
  { windowBackground: Color
  , pianoWhites: Color
  , pianoBlacks: Color
  , knobBackground: Color
  , knobForeground: Color
  , controlPanelBackground: Color
  , controlPanelBorders: Color
  }

defaultColorScheme : ColorScheme
defaultColorScheme =
  -- { windowBackground= Color.white
  { windowBackground= Color.red
  -- , pianoWhites= Color.white
  , pianoWhites= Color.green
  -- , pianoBlacks= Color.black
  , pianoBlacks= Color.blue
  , knobBackground= Color.black
  , knobForeground= Color.lightRed
  , controlPanelBackground= Color.white
  , controlPanelBorders= Color.black
  }

type alias GuiModel =
  { audioOn : Bool
  , slider1: Float
  , knobRegistry : KnobRegistry.Model
  , colorScheme: ColorScheme
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

type Action
  = AudioOn Bool
 | Slider1 Float
 | KnobRegistryAction KnobRegistry.Action

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
    KnobRegistryAction subAction ->
      { model |
          knobRegistry = KnobRegistry.update subAction model.knobRegistry
      }

guiMailbox : Signal.Mailbox Action
guiMailbox = Signal.mailbox (AudioOn True)

initialModel : GuiModel
initialModel =
  { audioOn = True
  , slider1 = 0.0
  , knobRegistry = KnobRegistry.init ["attack", "decay", "sustain", "release"]
  , colorScheme = defaultColorScheme
  }

guiModelSignal : Signal GuiModel
guiModelSignal =
    Signal.foldp
        updateGuiModel
        initialModel
        guiMailbox.signal



audioOnCheckbox : Signal.Address Action -> Bool -> Html
audioOnCheckbox address isChecked =
  div [ class "power-toggle"]
      [ input
          [ type' "checkbox"
          , id "power-toggle"
          , class "cmn-toggle cmn-toggle-round-flat"
          , checked isChecked
          , on "change" targetChecked (\isChecked -> Signal.message address (AudioOn isChecked))
          ]
          []
      , label [ for "power-toggle"] []
      -- , text (if isChecked then " (ON)" else " (OFF)")
      ]




-- -- MODEL
--
-- type alias Model =
--   { knobRegistry : KnobRegistry.Model
--   }
--
-- model : Model
-- model =
--   { knobRegistry = KnobRegistry.init ["attack", "decay", "sustain", "release"]
--   }
--
--
-- -- UPDATE
-- type Action
--   = KnobRegistryAction KnobRegistry.Action
--
-- update : Action -> Model -> Model
-- update action model =
--   case action of
--     KnobRegistryAction subAction ->
--       { model |
--           knobRegistry = KnobRegistry.update subAction model.knobRegistry
--       }
--
--
-- -- VIEW
--
-- view : Signal.Address Action -> Model -> Html.Html
-- view address model =
--   let
--     krAddress = (Signal.forwardTo address KnobRegistryAction)
--     knobView id =
--       KnobRegistry.view krAddress model.knobRegistry id
--
--
--
--
--   in
--     div
--       [ MouseExtra.onMouseMove
--           address
--           (\position -> KnobRegistryAction (MousePosition position))
--       , onMouseUp address (KnobRegistryAction GlobalMouseUp)
--       ]
--       [ knobView "attack"
--       , knobView "decay"
--       , knobView "sustain"
--       , knobView "release"
--       -- , knobView address KnobRegistryAction model.knobRegistry "attack"   -- this is about as good as it could possibly get
--       ]





view : Address Action -> GuiModel -> Html
view address model =  -- hwere is address??
  let
    krAddress = (Signal.forwardTo address KnobRegistryAction)
    knobView id =
      KnobRegistry.view krAddress model.knobRegistry id
  in
    div
        [ MouseExtra.onMouseMove
            address
            (\position -> KnobRegistryAction (MousePosition position))
        , onMouseUp address (KnobRegistryAction GlobalMouseUp)
        , class "elm-audio"
        , style ["background-color" => toCssRgb model.colorScheme.windowBackground]
        ]
        -- [ h1 [] [text "Elm Reactive Audio"]
        [ div [class "synth"]
          [ div [class "control-panel"]
            [ audioOnCheckbox guiMailbox.address model.audioOn
            -- , slider (Signal.forwardTo guiMailbox.address Slider1)
            , div [class "knobs"]
              [ knobView "attack"
              , knobView "decay"
              , knobView "sustain"
              , knobView "release"
              ]
            ]
          , piano
              { whiteKey = model.colorScheme.pianoWhites
              , blackKey = model.colorScheme.pianoBlacks
              }
              4
              12.0
          ]
        ]

guiSignal : Signal Html
guiSignal = Signal.map (view guiMailbox.address) guiModelSignal

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
  Signal.map5
    (\(mouseX, mouseY) (windowWidth, windowHeight) guiFrequency guiModel mouseVelocity ->
      let
        mouseWindowFraction'' = mouseWindowFraction' (mouseX, mouseY) (windowWidth, windowHeight)
        -- _ = Debug.log "velocity" velocity
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
    MouseExtra.velocity



type DragAction
    = DragStart (Signal.Address Action) Int
    | DragAt Int
    | DragEnd


-- task: Task Never a -> Effects a


trackDrags : Signal.Address DragAction -> Effects.Effects DragAction
trackDrags address =
  Effects.task (Native.Drag.track (Signal.send address << DragAt) DragEnd)


port outgoingUserInput : Signal UserInput
port outgoingUserInput = userInputSignal

main : Signal Html
main = guiSignal



-- var key_code = 65;
-- result should be
--
-- character = "a";
