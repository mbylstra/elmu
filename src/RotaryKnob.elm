module RotaryKnob where

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
  }


init : Model
init =
  { mouseDown = False
  , value = 0.0
  }


-- UPDATE

type Action
  = GlobalMouseUp -- a mouse up event anywhere
  | LocalMouseDown  -- a mouse down event on the knob
  | MouseMove Int  -- the number of pixels moved since the last one of these events
  | NoOp


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
    NoOp ->
      model

knobDisplay : Float -> Html.Html
knobDisplay value =
  let
    emptyAngle = 180.0 + 45.0
    fullAngle = -45.0
    valueAngle = (emptyAngle + 45.0) * value - 45.0
    radius = 80.0
    centerPoint = (100.0, 100.0)
  in
    svg
      [ width "200" , height "200" , viewBox "0 0 200 200" ]
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
          , strokeWidth "40"
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
          , strokeWidth "40"
          ]
          []
      ]

-- model is just used for display here
view : Address Action -> Model -> Html.Html
view address model =
  div []
    [ div
      [ style
          [ "width" => "200px"
          , "height" => "200px"
          , "position" => "relative"
          , "margin" => "20px"
          ]
      , onMouseDown address LocalMouseDown
      ]
      [ knobDisplay model.value ]
    ]
