module Gui.GridInput.Grid where

import Html exposing (..)
import Html.Attributes exposing (style, class)
import Html.Events exposing (onMouseDown, onMouseUp)

import Gui.GridInput.Cell as Cell exposing (Action, UpdateParams)

import Matrix exposing (Matrix)


-- MODEL

type alias Model =
  { cells : Matrix Cell.Model
  , mouseDown : Bool
  }

init : Int -> Int -> Model
init width height =
  { cells = Matrix.repeat width height (Cell.init False)
  , mouseDown = False
  }


-- UPDATE

type Action
  = MouseDown
  | MouseUp
  | CellAction { x : Int, y : Int} Cell.Action


update : Action -> Model -> Model
update action model =
  case action of
    CellAction pos cellAction ->
      let
        cellModel = Matrix.get pos.x pos.y
      in
        { model |
          cells = Matrix.update
            pos.x
            pos.y
            (Cell.update cellAction { mouseDown = model.mouseDown })
            model.cells
        }
    MouseDown ->
      { model | mouseDown = True }
    MouseUp ->
      { model | mouseDown = False }


-- VIEW


view : Signal.Address Action -> Model -> Html
view address model =
  div
    [ class "grid"
    , onMouseDown address MouseDown
    , onMouseUp address MouseUp
    ]
    ( Matrix.indexedMapListRows
      (\y row ->
        (rowView address y row)
      )
      model.cells
    )


rowView : Signal.Address Action -> Int -> List Cell.Model -> Html
rowView address y row =
  div [ class "row" ]
    ( List.indexedMap
      (\x cell ->
        (Cell.view (Signal.forwardTo address (CellAction {x=x, y=y})) cell)
      )
      row
    )
