import Mouse
import Html exposing (div)
import Dict exposing(Dict)

import MouseExtra

import RotaryKnob

import Html.Events exposing (onMouseUp)

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
  , mouse : { y : Int, yVelocity : Int}
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
  | GlobalMouseUp -- a mouse up event anywhere
  -- | MouseMove Int  -- the number of pixels moved since the last one of these events
  | MousePosition (Int, Int)  -- the number of pixels moved since the last one of these events
  | NoOp

update : Action -> Model -> Model
update action model =
  let
    _ = Debug.log "model" model
  in
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

mailbox : Signal.Mailbox Action
mailbox = Signal.mailbox NoOp

globalMouseUp : Signal Bool
globalMouseUp = Signal.filter (\isDown -> not isDown) True Mouse.isDown

actionSignal : Signal Action
actionSignal = mailbox.signal
-- actionSignal = Signal.mergeMany
--   [ mailbox.signal
--   -- , Signal.map MouseMove MouseExtra.yVelocity
--   -- , Signal.map (\_ -> GlobalMouseUp) globalMouseUp
--   ]


-- maybe if we used the mouse events rather than the signals, we could use
-- the regular startApp.simple, and this would reduce lines of code!

-- although, we need to get mouse position (using pageX)

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
  div
    [ MouseExtra.onMouseMove (Signal.forwardTo address MousePosition)
    , onMouseUp address GlobalMouseUp
    ]
    [ getKnobView model address "A"
    , getKnobView model address "B"
    , getKnobView model address "C"
    , getKnobView model address "D"
    ]

viewSignal : Signal Html.Html
viewSignal = Signal.map (\model -> view mailbox.address model) modelSignal

main : Signal Html.Html
main = viewSignal
