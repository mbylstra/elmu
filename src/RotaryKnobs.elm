import RotaryKnob

import Html exposing (..)
-- import Html.Attributes exposing(..)
-- import Html.Events exposing(onMouseDown)
-- import Mouse
-- import MouseExtra


-- MODEL

type alias Model =
  { knob1 : RotaryKnob.Model
  , knob2 : RotaryKnob.Model
  }


init : Model
init =
    { knob1 = RotaryKnob.init
    , knob2 = RotaryKnob.init
    }


-- UPDATE

type Action
  = Knob1 RotaryKnob.Action
  | Knob2 RotaryKnob.Action
  | NoOp

update : Action -> Model -> Model
update action model =
  let
    _ = Debug.log "update" True
  in
    case action of
      Knob1 action' ->
        { model |
          knob1 = RotaryKnob.update action' model.knob1
        }
      Knob2 action' ->
        { model |
          knob2 = RotaryKnob.update action' model.knob2
        }
      NoOp ->
        model



-- VIEW

mailbox : Signal.Mailbox Action
mailbox = Signal.mailbox NoOp

-- think here is were we merge in the signals?
-- actionSignal = Signal.merge mailbox.signal RotaryKnob.actionSignal

knob1Signal = Signal.map (\action -> Knob1 action) RotaryKnob.createActionSignal

knob2Signal = Signal.map (\action -> Knob2 action) RotaryKnob.createActionSignal

actionSignal : Signal Action
actionSignal = Signal.mergeMany
  [ mailbox.signal
  , knob1Signal
  , knob2Signal
  ]

-- we also need to forward on shit?


view : Signal.Address Action -> Model -> Html
view address model =
  div []
    [ RotaryKnob.view (Signal.forwardTo address Knob1) model.knob1
    , RotaryKnob.view (Signal.forwardTo address Knob2) model.knob2
    ]


modelSignal : Signal Model
modelSignal = Signal.foldp update init actionSignal

viewSignal : Signal Html
viewSignal = Signal.map (\model -> view mailbox.address model) modelSignal

main : Signal Html
main = viewSignal
