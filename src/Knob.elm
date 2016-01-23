module Knob where

import Html exposing (div)
import Html.Events exposing(onMouseDown)
import Html.Attributes exposing (style)

import Signal exposing (Address)

import Arc exposing (arc)

import Svg exposing (svg, path, rect)
import Svg.Attributes exposing (d, stroke, fill, strokeWidth, x, y, width, height, viewBox)


(=>) : a -> b -> ( a, b )
(=>) = (,)


-- MODEL

type alias Model =
  { mouseDown: Bool
  , value: Float -- A value from 0.0 to 1.0. The main thing the parent might care about
  , width: Int
  , height: Int
  }


init : Model
init =
  { mouseDown = False
  , value = 0.0
  , width = 100
  , height = 100
  }


-- UPDATE

type Action
  = GlobalMouseUp -- a mouse up event anywhere
  | LocalMouseDown  -- a mouse down event on the knob
  | MouseMove Int  -- the number of pixels moved since the last one of these events


clamp : Float -> Float
clamp x =
  if x > 1.0
  then 1.0
  else
    if x < 0.0
    then 0.0
    else x



update : Action -> Model -> Model
update action model =
  case action of
    LocalMouseDown ->
      { model | mouseDown = True}
    GlobalMouseUp ->
      { model | mouseDown = False}
    MouseMove pixels ->
      if
        model.mouseDown
      then
        let
          valueAdjust = (toFloat pixels) * 0.01   -- every pixel adjusts 0.01 of the value
        in
          { model | value = clamp (model.value + valueAdjust) }
      else
        model

knobDisplay : Model -> Html.Html
knobDisplay model =
  let
    emptyAngle = 180.0 + 45.0
    fullAngle = -45.0
    valueAngle = (emptyAngle + 45.0) * model.value - 45.0
    widthFloat = toFloat model.width
    radius = (widthFloat / 2.0) - 20.0
    centerPoint = (widthFloat / 2.0, widthFloat / 2.0)
    widthStr = toString model.width
    heightStr = toString model.height
    strokeWidthStr = toString (widthFloat / 10.0)
  in
    svg
      [ width widthStr
      , height heightStr
      , viewBox ("0 0 " ++ widthStr ++ " " ++ heightStr) -- this should be params, coming from model (why not)
      ]
      [ path
          [ d (arc
                { radius=radius
                , centerPoint=centerPoint
                , startAngle=fullAngle
                , endAngle=valueAngle
                }
              )
          , stroke "black"
          , fill "none"
          , strokeWidth strokeWidthStr
          ]
          []
      , path
          [ d (arc
                { radius=radius
                , centerPoint=centerPoint
                , startAngle=valueAngle
                , endAngle=emptyAngle
                }
              )
          , stroke "pink"
          , fill "none"
          , strokeWidth strokeWidthStr
          ]
          []
      ]

-- model is just used for display here
view : Address Action -> Model -> Html.Html
view address model =
  div []
    [ div
      [ style
          [ "width" => toString model.width
          , "height" => toString model.width
          , "padding" => "10px"
          -- , "border-radius" => "10px"
          , "position" => "relative"
          , "margin" => "10px"
          , "background-color" => if model.mouseDown then "#EEE" else "white"
          , "border" => "1px solid #CCC"
          ]
      , onMouseDown address LocalMouseDown
      ]
      [ knobDisplay model ]
    ]
