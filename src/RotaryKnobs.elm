import Html exposing (div)
import Dict exposing(Dict)
import StartApp.Simple as StartApp

import MouseExtra

import RotaryKnob

import Html.Events exposing (onMouseUp)

type alias ID = String

type alias Knobs = Dict ID RotaryKnob.Model



-- MODEL

type alias Model =
  { knobs : Knobs
  , currentKnob : Maybe ID
  , mouse : { y : Int, yVelocity : Int}
  }

model : Model
model =
    { knobs = Dict.fromList
      [ ("A", RotaryKnob.init)
      , ("B", RotaryKnob.init)
      , ("C", RotaryKnob.init)
      , ("D", RotaryKnob.init)
      ]
    , currentKnob = Nothing
    , mouse = { y = 0, yVelocity = 0}
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
  | GlobalMouseUp
  | MousePosition (Int, Int)
  | NoOp

update : Action -> Model -> Model
update action model =
  case action of
    KnobAction id action' ->
      { model |
          knobs = Dict.update id (updateKnob action') model.knobs
        , currentKnob = Just id
      }

    MousePosition (x,y) ->
      let
        newMouse =
          { y = y
          , yVelocity = y - model.mouse.y
          }

      in
        case model.currentKnob of
          Just id ->
            { model |
                knobs = Dict.update
                  id
                  (updateKnob (RotaryKnob.MouseMove newMouse.yVelocity))
                  model.knobs
              , mouse = newMouse
            }
          Nothing ->
            { model | mouse = newMouse }

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

knobView : Model -> Signal.Address Action -> ID -> Html.Html
knobView model address id =
  let
    knob = getKnob model.knobs id
  in
    RotaryKnob.view (Signal.forwardTo address (KnobAction id)) knob


view : Signal.Address Action -> Model -> Html.Html
view address model =
  div
    [ MouseExtra.onMouseMove (Signal.forwardTo address MousePosition)
    , onMouseUp address GlobalMouseUp
    ]
    [ knobView model address "A"
    , knobView model address "B"
    , knobView model address "C"
    , knobView model address "D"
    ]

main : Signal Html.Html
main =
  StartApp.start { model = model, view = view, update = update }
