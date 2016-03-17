module Gui.GridInput.Cell
  ( init
  , update
  , view
  , Model
  , Action
  , UpdateParams
  )
  where

import Html exposing (..)
import Html.Attributes exposing (classList)
import Html.Events exposing (onClick, onMouseDown, onMouseEnter, onMouseLeave)


-- MODEL

type alias Model = Bool -- Is the cell on or off?

init : Bool -> Model
init model = model


-- UPDATE

{- "Params" for the update function. A pattern I'm trialing -}
type alias UpdateParams =
  { mouseDown : Bool }

type Action = MouseDown | MouseEnter | MouseLeave

update : Action -> UpdateParams -> Model -> Model
update action params model =
  case action of
    MouseDown ->
      model
    MouseEnter ->
      if params.mouseDown
      then
        True
      else
        model
    MouseLeave ->
      model


-- VIEW

view : Signal.Address Action -> Model -> Html
view address model =
  div
    [ onMouseDown address MouseDown
    , onMouseEnter address MouseEnter
    , onMouseLeave address MouseLeave
    , classList [("cell", True), ("active", model)]
    ]
    []
