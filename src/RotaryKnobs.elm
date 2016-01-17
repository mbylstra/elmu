
import Mouse
import Html exposing (div)
import Dict exposing(Dict)

import MouseExtra

import RotaryKnob

type alias ID = String

type alias Knobs = Dict ID RotaryKnob.Model

-- knobRegistry : Dict ID String
-- knobRegistry = Dict.empty

-- maybe we can make a knobPack, which generates some kind of thing that contains
-- functions n crap, and we pass in the current list of knobs, and it gets
-- updated


-- MODEL

type alias Model =
  { knobs : Knobs
  , currentKnob : Maybe ID
  }


-- type alias Model =
--     { counters : List ( ID, Counter.Model )
--     , nextID : ID
--     }


init : Model
init =
    { knobs = Dict.fromList
      [ ("A", RotaryKnob.init)
      , ("B", RotaryKnob.init)
      , ("C", RotaryKnob.init)
      ]
    , currentKnob = Nothing
    }


getKnob : Knobs -> ID -> RotaryKnob.Model
getKnob knobs id =
  case (Dict.get id knobs) of
    Just knob -> knob
    Nothing -> Debug.crash("No knob exists with id: " ++ id)

updateKnob : RotaryKnob.Action -> Maybe RotaryKnob.Model -> Maybe RotaryKnob.Model
updateKnob action =
  let
    updateKnob' : Maybe RotaryKnob.Model -> Maybe RotaryKnob.Model
    updateKnob' knob =
      case knob of
        Just knob' ->
          Just (RotaryKnob.update action knob')
        Nothing ->
          Nothing
  in
    updateKnob'




-- UPDATE

type Action
  = KnobAction ID RotaryKnob.Action
  | GlobalMouseUp -- a mouse up event anywhere
  | MouseMove Int  -- the number of pixels moved since the last one of these events
  | NoOp

update : Action -> Model -> Model
update action model =
  case action of
    KnobAction id action' ->
      { model |
          knobs = Dict.update id (updateKnob action') model.knobs
        , currentKnob = Just id
      }

    MouseMove i ->
      case model.currentKnob of
        Just id ->
          { model |
            knobs = Dict.update id (updateKnob (RotaryKnob.MouseMove i)) model.knobs
          }
        Nothing ->
          model

    GlobalMouseUp ->
      case model.currentKnob of
        Just id ->
          { model |
            knobs = Dict.update id (updateKnob RotaryKnob.GlobalMouseUp) model.knobs
          }
        Nothing ->
          model

    NoOp ->
      model


-- VIEW

mailbox : Signal.Mailbox Action
mailbox = Signal.mailbox NoOp

globalMouseUp : Signal Bool
globalMouseUp = Signal.filter (\isDown -> not isDown) True Mouse.isDown

actionSignal : Signal Action
actionSignal = Signal.mergeMany
  [ mailbox.signal
  , Signal.map MouseMove MouseExtra.yVelocity
  , Signal.map (\_ -> GlobalMouseUp) globalMouseUp
  ]

modelSignal : Signal Model
modelSignal = Signal.foldp update init actionSignal

getKnobView : Model -> Signal.Address Action -> ID -> Html.Html
getKnobView model address id =
  let
    knob = getKnob model.knobs id
  in
    RotaryKnob.view (Signal.forwardTo address (KnobAction id)) knob



view : Signal.Address Action -> Model -> Html.Html
view address model =
  div []
    [ getKnobView model address "A"
    , getKnobView model address "B"
    , getKnobView model address "C"
    ]

viewSignal : Signal Html.Html
viewSignal = Signal.map (\model -> view mailbox.address model) modelSignal

main : Signal Html.Html
main = viewSignal
