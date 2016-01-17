import RotaryKnob

import Mouse
import MouseExtra

import Html exposing (..)
-- import Html.Attributes exposing(..)
-- import Html.Events exposing(onMouseDown)
-- import Mouse
-- import MouseExtra


-- MODEL

type alias Model =
  { knob1 : RotaryKnob.Model
  , knob2 : RotaryKnob.Model
  , currentKnob : CurrentKnob
  }



-- I don't think it hurts to know the *currently active knob*
-- with that data, you could show status offscren, or show more
-- detail somewhere else in the UI, without being constrained
-- by the screen realestate of the knob! (this is good!)

init : Model
init =
    { knob1 = RotaryKnob.init
    , knob2 = RotaryKnob.init
    , currentKnob = None
    }


-- UPDATE

type CurrentKnob
  = Knob1
  | Knob2
  | None

type Action
  = Knob1Action RotaryKnob.Action
  | Knob2Action RotaryKnob.Action
  | GlobalMouseUp -- a mouse up event anywhere
  | MouseMove Int  -- the number of pixels moved since the last one of these events
  | NoOp

update : Action -> Model -> Model
update action model =
  let
    _ = Debug.log "main update" True
  in
    case action of
      Knob1Action action' ->
        { model |
            knob1 = RotaryKnob.update action' model.knob1
          , currentKnob = Knob1
        }
      Knob2Action action' ->
        { model |
            knob2 = RotaryKnob.update action' model.knob2
          , currentKnob = Knob2
        }
      MouseMove i ->
        case model.currentKnob of
          Knob1 ->
            { model |
              knob1 = RotaryKnob.update (RotaryKnob.MouseMove i) model.knob1
            }
          Knob2 ->
            { model |
              knob2 = RotaryKnob.update (RotaryKnob.MouseMove i) model.knob2
            }
          None ->
            model
      GlobalMouseUp ->
        case model.currentKnob of
          Knob1 ->
            { model |
              knob1 = RotaryKnob.update (RotaryKnob.GlobalMouseUp) model.knob1
            }
          Knob2 ->
            { model |
              knob2 = RotaryKnob.update (RotaryKnob.GlobalMouseUp) model.knob2
            }
          None ->
            model
      NoOp ->
        model


-- VIEW

mailbox : Signal.Mailbox Action
mailbox = Signal.mailbox NoOp

globalMouseUp : Signal Bool
globalMouseUp = Signal.filter (\isDown -> not isDown) True Mouse.isDown

-- think here is were we merge in the signals?
-- actionSignal = Signal.merge mailbox.signal RotaryKnob.actionSignal

-- createActionSignal : Signal Action
-- createActionSignal =
--   let
--     mailbox : Signal.Mailbox Action
--     mailbox = Signal.mailbox NoOp
--   in

-- knob1Signal = Signal.map (\action -> Knob1 action) RotaryKnob.createActionSignal
--
-- knob2Signal = Signal.map (\action -> Knob2 action) RotaryKnob.createActionSignal


-- we can only have one mouseMove (or the events will cancel each other out),
-- so that needs to be routed, but depends on which one is currently active??
--    OR, we make this part of our main model (here), but forward on that state
-- I THINK THIS IS IT!

actionSignal : Signal Action
actionSignal = Signal.mergeMany
  [ mailbox.signal
  , Signal.map MouseMove MouseExtra.yVelocity
  , Signal.map (\_ -> GlobalMouseUp) globalMouseUp
  ]

--     Signal.mergeMany
--       [ Signal.map MouseMove MouseExtra.yVelocity
--       , Signal.map (\_ -> GlobalMouseUp) globalMouseUp
--       , mailbox.signal
--       ]

-- we also need to forward on shit?


view : Signal.Address Action -> Model -> Html
view address model =
  div []
    [ RotaryKnob.view (Signal.forwardTo address Knob1Action) model.knob1
    , RotaryKnob.view (Signal.forwardTo address Knob2Action) model.knob2
    ]


modelSignal : Signal Model
modelSignal = Signal.foldp update init actionSignal

viewSignal : Signal Html
viewSignal = Signal.map (\model -> view mailbox.address model) modelSignal

main : Signal Html
main = viewSignal
