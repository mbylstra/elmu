module Gui where

--------------------------------------------------------------------------------
-- IMPORT
--------------------------------------------------------------------------------

import Effects exposing (Never, Effects)
import StartApp exposing (App)
-- import Task
import Random exposing (Seed)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (on, targetChecked, onMouseUp)
import Signal exposing (Address)
import Maybe exposing (withDefault)
import Array
import Effects

import Helpers exposing (prefixDict)

import Lib.ColorExtra as ColorExtra exposing (toCssRgb)
import Lib.MouseExtra as MouseExtra
import Lib.HtmlAttributesExtra exposing (..)

import Gui.Piano as Piano exposing (piano, pianoSignal, pianoGuiFrequency)
import Gui.KeyboardNoteInput as KeyboardNoteInput exposing (keyboardGuiFrequency)
import Gui.ColorScheme as ColorScheme exposing (defaultColorScheme, ColorScheme, fromColourLovers)
import Gui.ColorSchemeChooser as ColorSchemeChooser
import Gui.Knob as Knob
import Gui.KnobRegistry as KnobRegistry exposing (Action(GlobalMouseUp, MousePosition), getKnobValue)


import Apis.ColourLovers as ColourLovers
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
  , colourLovers : ColourLovers.Model
  , colorSchemeChooser : ColorSchemeChooser.Model
  }

init : (Model, Effects Action)
init =

  let
    (colourLovers, palettesFx) = ColourLovers.init
    defaultParams = Knob.defaultParams
  in
  (
    { audioOn = True
    , frequency = 400.0
    , knobRegistry = KnobRegistry.init
      [ ("attack", Knob.defaultParams)
      , ("decay", Knob.defaultParams)
      , ("sustain", Knob.defaultParams)
      , ("release", Knob.defaultParams)
      ]
    , colourLovers = colourLovers
    , colorSchemeChooser = ColorSchemeChooser.init randomSeed defaultColorScheme
    }
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

getFrequency :Model -> Float
getFrequency model =
  model.frequency

getAttack : Model -> Float
getAttack model =
  KnobRegistry.getKnobValue model.knobRegistry "attack"

type alias EncodedModel =
  { audioOn : Bool
  , frequency : Float
  , knobs : KnobRegistry.EncodedModel
  }

encode : Model -> EncodedModel
encode model =
  let
    knobs = KnobRegistry.encode model.knobRegistry
    knobs' = prefixDict ".knobs" knobs
    -- _ = Debug.log "knobs encoded" knobs
    encoded =
      { audioOn = model.audioOn
      , frequency = model.frequency
      , knobs = knobs'
      }
    -- encoded
    -- _ = Debug.log "encoded:" encoded
  in
    encoded




(initModel, _) = init

initialEncodedModel : EncodedModel
initialEncodedModel = encode initModel

--------------------------------------------------------------------------------
-- UPDATE
--------------------------------------------------------------------------------

type Action
  = AudioOn Bool
  | KnobRegistryAction KnobRegistry.Action
  | ChangeFrequency Float
  | ColourLoversAction ColourLovers.Action
  | ColorSchemeChooserAction ColorSchemeChooser.Action


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
        colorSchemeChooser = ColorSchemeChooser.setColorSchemes model.colorSchemeChooser colorSchemes
        newModel =
          { model |
              colourLovers = colourLovers2
            , colorSchemeChooser = colorSchemeChooser
          }
      in
        ( newModel
        , Effects.map ColourLoversAction clFx
        )
    ColorSchemeChooserAction childAction ->
      let
        colorSchemeChooser2 = ColorSchemeChooser.update childAction model.colorSchemeChooser

        -- This is likely an anti pattern, but if ColorSchemeChooser model has changed,
        -- there's a chance that the color scheme has changed, so we should update
        -- the knobs' models. It's unclear whether the knob color is *derived* data,
        -- or whether it should live in the state of the knob. If it's derived
        -- data, then should this data be passed down through the view function?
        -- Pretty big question marks. What comes next does not feel right...
        colorScheme = ColorSchemeChooser.getColorScheme colorSchemeChooser2
        knobDefaultParams = Knob.defaultParams -- this is ugly becuase you can't have dots in record update syntax
        params =
          { knobDefaultParams |
              foregroundColor = colorScheme.knobForeground
            , backgroundColor = colorScheme.knobBackground
          }
        knobRegistry2 = KnobRegistry.update
          (KnobRegistry.UpdateParamsForAll params)
          model.knobRegistry
      in
        ( { model |
              colorSchemeChooser = colorSchemeChooser2
            , knobRegistry = knobRegistry2
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
    colorScheme = ColorSchemeChooser.getColorScheme model.colorSchemeChooser
  in
    div
        [ MouseExtra.onMouseMove
            address
            (\position -> KnobRegistryAction (MousePosition position))
        , onMouseUp address (KnobRegistryAction GlobalMouseUp)
        , class "elm-audio"
        , style ["background-color" => toCssRgb colorScheme.windowBackground]
        ]
        [ div [class "synth"]
          [ h1 [] [text "elmu"]
          , div [class "control-panel"]
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
              { whiteKey = colorScheme.pianoWhites
              , blackKey = colorScheme.pianoBlacks
              }
              4
              12.0
          ]
        , ColorSchemeChooser.view (Signal.forwardTo address ColorSchemeChooserAction) model.colorSchemeChooser
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

-- port tasks : Signal (Task.Task Never ())
-- port tasks =
--   app.tasks

-- port outgoingUiModel : Signal EncodedModel
-- port outgoingUiModel =
--   Signal.map encode app.model

-- port randomPrimer : Float



--------------------------------------------------------------------------------
-- ???
--------------------------------------------------------------------------------

-- I guess we could use main instead?
dummy : String
dummy = "dummy!"
