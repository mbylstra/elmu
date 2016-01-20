import Html exposing (div)
import StartApp.Simple as StartApp
import Html.Events exposing (onMouseUp)

import MouseExtra
import KnobRegistry exposing (Action(GlobalMouseUp, MousePosition))


-- MODEL

type alias Model =
  { knobRegistry : KnobRegistry.Model
  }

model : Model
model =
  { knobRegistry = KnobRegistry.init ["attack", "decay", "sustain", "release"]
  }


-- UPDATE
type Action
  = KnobRegistryAction KnobRegistry.Action

update : Action -> Model -> Model
update action model =
  case action of
    KnobRegistryAction subAction ->
      { model |
          knobRegistry = KnobRegistry.update subAction model.knobRegistry
      }


-- VIEW

view : Signal.Address Action -> Model -> Html.Html
view address model =
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
      ]
      [ knobView "attack"
      , knobView "decay"
      , knobView "sustain"
      , knobView "release"
      -- , knobView address KnobRegistryAction model.knobRegistry "attack"   -- this is about as good as it could possibly get
      ]

main : Signal Html.Html
main =
  StartApp.start { model = model, view = view, update = update }
