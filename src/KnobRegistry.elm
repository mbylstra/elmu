module KnobRegistry
  ( init
  , Model
  , Action(GlobalMouseUp, MousePosition)
  , update
  , view
  )
  where

import Dict exposing (Dict)
import Knob
import Html exposing (div)

type alias ID = String
type alias Knobs = Dict ID Knob.Model

type Action
  = KnobAction ID Knob.Action
  | GlobalMouseUp
  | MousePosition (Int, Int)

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
          }
        Nothing ->
          model



-- so the *maybe big* issue here is that we need to accept any type
-- constructor..
  -- can yuo

view : Signal.Address Action -> Model -> ID -> Html.Html
view address model id =
  let
    knob = getKnob model.knobs id
  in
    Knob.view (Signal.forwardTo address (KnobAction id)) knob

-- -- VIEW
-- -- so it gets a bit trickier here....
--
-- knobView : Model -> Signal.Address Action -> Knob.ID -> Html.Html
-- knobView model address id =
--   let
--     knob = Knob.getKnob model.knobs id
--   in
--     Knob.view (Signal.forwardTo address (KnobAction id)) knob
--
-- view : Signal.Address Action -> Model -> Html.Html
-- view address model =
--   div
--     [ MouseExtra.onMouseMove (Signal.forwardTo address MousePosition)
--     , onMouseUp address GlobalMouseUp
--     ]
--     [ knobView model address "A"
--     , knobView model address "B"
--     , knobView model address "C"
--     , knobView model address "D"
--     ]




-- Type ParentAction = ChildAction Child.Action
-- Address ParentAction    (KnobAction)
-- Address ChildAction     (MouseDown)

-- Child is the one that adds a listener, and it sends the event
-- to the address that the thing calling it passes in. This way events
-- flow up the tree. The Root node is responsible for passing the event down
-- to the right update function. I think it's possible to forwardTo consecutively
-- (GranParent passes forwardTo to parent that does forwardTo to child)
---- I think maybe the key is that GrandParent does not call grandChild view directly,
---- Rather it calls the Parent view with the id of a grandchild, and the parent
---- forwards on to grand child.

-- Eg: ParentAction KnobAction MouseDown

-- forwardTo : Address b -> (a -> b) -> Address a
-- forwardTo (Address send) f =
--     Address (\x -> send (f x))



  [ MouseExtra.onMouseMove
          address
          (\position -> KnobRegistryAction (MousePosition position))
      , onMouseUp address (KnobRegistryAction GlobalMouseUp)

  -- , knobView address KnobRegistryAction model.knobRegistry "attack"   -- this is about as good as it could possibly get
