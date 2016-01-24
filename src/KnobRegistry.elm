module KnobRegistry
  ( init
  , Model
  , EncodedModel
  , Action(GlobalMouseUp, MousePosition)
  , update
  , view
  , encode
  )
  where

--------------------------------------------------------------------------------
-- IMPORT
--------------------------------------------------------------------------------

import Dict exposing (Dict)
import Knob
import Html exposing (div)


--------------------------------------------------------------------------------
-- MODEL
--------------------------------------------------------------------------------

type alias ID = String
type alias Knobs = Dict ID Knob.Model
type alias Model =
  { knobs : Knobs
  , currentKnob : Maybe ID
  , mouse : { y : Int, yVelocity : Int}
  }

init : List String -> Model
init names =
  { knobs = Dict.fromList <| List.map (\name -> (name, Knob.init)) names
  , currentKnob = Nothing
  , mouse = { y = 0, yVelocity = 0}
  }

getKnob : Knobs -> ID -> Knob.Model
getKnob knobs id =
  case (Dict.get id knobs) of
    Just knob -> knob
    Nothing -> Debug.crash("No knob exists with id: " ++ id)

type alias EncodedModel =
  List (ID, Knob.EncodedModel)

encode : Model -> EncodedModel
encode model =
  List.map
    (\(k, v) -> (k, Knob.encode v))
    (Dict.toList model.knobs)


--------------------------------------------------------------------------------
-- UPDATE
--------------------------------------------------------------------------------

type Action
  = KnobAction ID Knob.Action
  | GlobalMouseUp
  | MousePosition (Int, Int)


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
                  (updateKnob (Knob.MouseMove newMouse.yVelocity))
                  model.knobs
              , mouse = newMouse
            }
          Nothing ->
            { model | mouse = newMouse }

    GlobalMouseUp ->
      case model.currentKnob of
        Just id ->
          { model |
              knobs = Dict.update id (updateKnob Knob.GlobalMouseUp) model.knobs
              , currentKnob = Nothing
          }
        Nothing ->
          model

updateKnob : Knob.Action -> Maybe Knob.Model -> Maybe Knob.Model
updateKnob action =
  let
    updateKnob' : Maybe Knob.Model -> Maybe Knob.Model
    updateKnob' knob =
      case knob of
        Just knob' ->
          Just (Knob.update action knob')
        Nothing ->
          Nothing
  in
    updateKnob'

--------------------------------------------------------------------------------
-- VIEW
--------------------------------------------------------------------------------

view : Signal.Address Action -> Model -> ID -> Html.Html
view address model id =
  let
    knob = getKnob model.knobs id
  in
    Knob.view (Signal.forwardTo address (KnobAction id)) knob
