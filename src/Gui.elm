module Gui where

--------------------------------------------------------------------------------
-- IMPORT
--------------------------------------------------------------------------------

import Effects exposing (Never, Effects)
import StartApp exposing (App)
import Task
import Random exposing (Seed)


import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (on, targetChecked, onMouseUp)
import Piano exposing (piano, pianoSignal, pianoGuiFrequency)
import KeyboardNoteInput exposing (keyboardGuiFrequency)
-- import Slider exposing (slider)
import Signal exposing (Address)
import Array
import Maybe exposing (withDefault)

import ColorExtra exposing (toCssRgb)

import ColourLovers


import MouseExtra

import Effects


import MouseExtra
import KnobRegistry exposing (Action(GlobalMouseUp, MousePosition))
import HtmlAttributesExtra exposing (..)

import ColorScheme exposing (defaultColorScheme, ColorScheme, fromColourLovers)
import ColorSchemeChooser

--------------------------------------------------------------------------------
-- RANDOMNESS
--------------------------------------------------------------------------------


-- this stuff should all belong in ColourSchemeChooser! (what a hassle!)

randomPrimer : Float
randomPrimer = 0.0

randomSeed : Seed
randomSeed =
  Random.initialSeed <| round randomPrimer  -- see PORTS section


--------------------------------------------------------------------------------
-- MODEL
--------------------------------------------------------------------------------

type alias Model =
  { audioOn : Bool
  , frequency : Float
  , knobRegistry : KnobRegistry.Model
  , colorScheme : ColorScheme -- consider just using the value inside colorSchemeChooser (or not?)
  , colourLovers : ColourLovers.Model
  , colorSchemeChooser : ColorSchemeChooser.Model
  }

init : (Model, Effects Action)
init =

  let
    (colourLovers, palettesFx) = ColourLovers.init
  in
  (
    { audioOn = True
    , frequency = 400.0
    , knobRegistry = KnobRegistry.init ["attack", "decay", "sustain", "release"]
    , colorScheme = defaultColorScheme
    , colourLovers = colourLovers
    , colorSchemeChooser = ColorSchemeChooser.init randomSeed defaultColorScheme
    }
  -- , ColourLovers.initEffects
  , Effects.batch
    [ Effects.map ColourLoversAction palettesFx
    ]
  )

-- init : String -> String -> (Model, Effects Action)
-- init leftTopic rightTopic =
--   let
--     (left, leftFx) = RandomGif.init leftTopic
--     (right, rightFx) = RandomGif.init rightTopic
--   in
--     ( Model left right
--     , Effects.batch
--         [ Effects.map Left leftFx
--         , Effects.map Right rightFx
--         ]
--     )


type alias EncodedModel =
  { audioOn : Bool
  , frequency : Float
  , knobs : KnobRegistry.EncodedModel
  }

encode : Model -> EncodedModel
encode model =
  { audioOn = model.audioOn
  , frequency = model.frequency
  , knobs = KnobRegistry.encode model.knobRegistry
  }


--------------------------------------------------------------------------------
-- UPDATE
--------------------------------------------------------------------------------

type Action
  = AudioOn Bool
  | KnobRegistryAction KnobRegistry.Action
  | ChangeFrequency Float
  | ColourLoversAction ColourLovers.Action
  | ColorSchemeAction ColorSchemeChooser.Action


update : Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    AudioOn value ->
      ( { model | audioOn = value }
      , Effects.none
      )
    KnobRegistryAction childAction ->
      ( { model |
            knobRegistry = KnobRegistry.update childAction model.knobRegistry
        }
      , Effects.none
      )
    ChangeFrequency f ->
      ( { model | frequency = f }
      , Effects.none
      )
    ColourLoversAction childAction ->
      let
        (colourLovers2, clFx) = ColourLovers.update childAction model.colourLovers
        maybePalettes = ColourLovers.getPalettes colourLovers2
        colorSchemes =
          case maybePalettes of
            Just palettes -> ColorScheme.fromColourLoversArray palettes
            Nothing -> Array.empty
        _ = Debug.log "colorSchemes" colorSchemes
        colorSchemeChooser = ColorSchemeChooser.setColorSchemes model.colorSchemeChooser colorSchemes
        newModel =
          { model |
              colourLovers = colourLovers2
            , colorSchemeChooser = colorSchemeChooser
          }
        _ = Debug.log "newModel" newModel.colorSchemeChooser
      in
        ( newModel
        , Effects.map ColourLoversAction clFx
        )
    ColorSchemeAction childAction ->
      let
        colorSchemeChooser2 = ColorSchemeChooser.update childAction model.colorSchemeChooser
      in
        ( { model |
              colorSchemeChooser = colorSchemeChooser2
            , colorScheme = ColorSchemeChooser.getCurrent colorSchemeChooser2
          }
        , Effects.none
        )


-- TODO: this should be moved into separate module. forwardTo is required
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
      ]

--------------------------------------------------------------------------------
-- VIEW
--------------------------------------------------------------------------------

view : Address Action -> Model -> Html
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
            [ audioOnCheckbox address model.audioOn
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
        , ColorSchemeChooser.view (Signal.forwardTo address ColorSchemeAction) model.colorSchemeChooser
        ]


--------------------------------------------------------------------------------
-- EFFECTS
--------------------------------------------------------------------------------

guiFrequency : Signal Float
guiFrequency =
  Signal.merge keyboardGuiFrequency pianoGuiFrequency

guiFrequencyActionSignal : Signal Action
guiFrequencyActionSignal =
  Signal.map (\f -> ChangeFrequency f) guiFrequency


--------------------------------------------------------------------------------
-- APP
--------------------------------------------------------------------------------

app : App Model
app =
  StartApp.start
    { init = init
    , update = update
    , view = view
    , inputs = [guiFrequencyActionSignal]
    }

main : Signal Html
main = app.html

--------------------------------------------------------------------------------
-- PORTS
--------------------------------------------------------------------------------

port tasks : Signal (Task.Task Never ())
port tasks =
  app.tasks

port outgoingUiModel : Signal EncodedModel
port outgoingUiModel =
  Signal.map encode app.model

-- port randomPrimer : Float



--------------------------------------------------------------------------------
-- ???
--------------------------------------------------------------------------------

dummy : String
dummy = "dummy!"
