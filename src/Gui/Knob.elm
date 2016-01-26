module Gui.Knob where

import Html exposing (div)
import Html.Events exposing(onMouseDown, onMouseEnter, onMouseLeave, Options)
import Html.Attributes exposing (style, classList)
import Color exposing (Color)
import Signal exposing (Address)
import Svg exposing (svg, path, rect, line)
import Svg.Attributes exposing (d, stroke, fill, strokeWidth, x, y, x1, y1, x2, y2, width, height, viewBox)

import Lib.HtmlEventsExtra exposing (onMouseDownWithOptions, preventDefault)
import Lib.Arc exposing (arc, getArcInfo)
import Lib.HtmlAttributesExtra exposing (..)
import Lib.ColorExtra exposing (toCssRgb)




-- MODEL

type alias Model =
  { params: Params
  , mouseDown: Bool
  , mouseInside: Bool
  , value: Float -- A value from 0.0 to 1.0. The main thing the parent might care about
  }

type alias Params =
  { foregroundColor : Color
  , backgroundColor : Color
  , width : Int
  , height : Int
  }

defaultParams : Params
defaultParams =
  { foregroundColor = Color.green
  , backgroundColor = Color.black
  , width = 100
  , height = 100
  }

init : Params -> Model
init params =
  { params = params
  , value = 0.0
  , mouseDown = False
  , mouseInside = False
  }

type alias EncodedModel = Float

encode : Model -> EncodedModel
encode model =
  model.value

-- UPDATE

type Action
  = GlobalMouseUp -- a mouse up event anywhere
  | MouseDown  -- a mouse down event on the knob
  | MouseMove Int  -- the number of pixels moved since the last one of these events
  | MouseEnter
  | MouseLeave
  | UpdateParams Params


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
    MouseDown ->
      { model | mouseDown = True}
    MouseEnter ->
      { model | mouseInside = True}
    MouseLeave ->
      { model | mouseInside = False}
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
    UpdateParams params ->
      { model | params = params }

knobDisplay : Model -> Html.Html
knobDisplay model =
  let
    emptyAngle = 180.0 + 89.0
    fullAngle = -90.0
    -- emptyAngle = 359.0
    -- fullAngle = 0.0
    valueAngle = (emptyAngle + 90.0) * model.value - 90.0
    widthFloat = toFloat model.params.width
    radius = (widthFloat / 2.0) - 20.0
    centerPoint = (widthFloat / 2.0, widthFloat / 2.0)
    widthStr = toString model.params.width
    heightStr = toString model.params.height
    strokeWidth' = widthFloat / 10.0
    strokeWidthStr = toString strokeWidth'
    activeArcArgs =
      { radius=radius
      , centerPoint=centerPoint
      , startAngle=valueAngle
      , endAngle=emptyAngle
      }
    inactiveArcArgs =
      { radius=radius
      , centerPoint=centerPoint
      , startAngle=fullAngle
      , endAngle=valueAngle
      }
    needleArcArgs =
      { radius=radius + (strokeWidth' / 2.0)
      , centerPoint=centerPoint
      , startAngle=valueAngle
      , endAngle=emptyAngle
      }
    activeArcInfo = getArcInfo needleArcArgs
    (needleX1, needleY1) = activeArcInfo.centerPoint
    (needleX2, needleY2) = activeArcInfo.startPoint
  in
    svg
      [ width widthStr
      , height heightStr
      , viewBox ("0 0 " ++ widthStr ++ " " ++ heightStr) -- this should be params, coming from model (why not)
      ]
      [ path
          [ d (arc inactiveArcArgs)
          , stroke <| toCssRgb model.params.backgroundColor
          , fill "none"
          , strokeWidth strokeWidthStr
          ]
          []
      , path
          [ d (arc activeArcArgs)
          , stroke <| toCssRgb model.params.foregroundColor
          , fill "none"
          , strokeWidth strokeWidthStr
          ]
          []
      , line
          [ x1 (toString needleX1)
          , y1 (toString needleY1)
          , x2 (toString needleX2)
          , y2 (toString needleY2)
          , stroke <| toCssRgb model.params.foregroundColor
          , fill "none"
          , strokeWidth (toString 2.0)
          ]
          []
      ]

-- model is just used for display here
view : Address Action -> Model -> Html.Html
view address model =
  div []
    [ div
      [ style
          [ "width" => toString model.params.width
          , "height" => toString model.params.width
          , "padding" => "10px"
          , "position" => "relative"
          , "margin" => "10px"
          ]
      , classList [ ("highlighted", model.mouseInside || model.mouseDown) ]
      , onMouseDownWithOptions preventDefault address MouseDown
      , onMouseEnter address MouseEnter
      , onMouseLeave address MouseLeave
      ]
      [ knobDisplay model ]
    ]
