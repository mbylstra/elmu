module RotaryKnob where

import Html exposing (div)
import Html.Events exposing(onMouseDown)
import Html.Attributes exposing (style)
-- import Mouse
-- import MouseExtra

import Signal exposing (Address)

import Arc exposing (arc)

import Svg exposing (svg, path, rect)
import Svg.Attributes exposing (d, stroke, fill, strokeWidth, x, y, width, height, viewBox)


-- Mouse.position
-- Mouse.isDown

-- maybe filter out if isDown? filterMap?

(=>) : a -> b -> ( a, b )
(=>) = (,)

-- onMouseDown : Signal.Address a -> a -> Attribute


-- this thing here needs to update its state based on mouse move, but
-- the state must live at the top (kind of annoying)
-- maybe we can pass a function that takes care of updating the state?
--  it should take

-- we can easily make a new signal using foldp, that provides a signal of
-- movements (vectors?, ) since last mouseMove, and then break that up into horizontal
-- and vertical, provide this signal as a library function

-- we need an id for every knob, and state for every knob




-- MODEL

type alias Model =
  { mouseDown: Bool
  , value: Float -- A value from 0.0 to 1.0. The main thing the parent might care about
  }

-- type alias InternalModel = -- we might need this!


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
      [ knobDisplay model.value
      ]
    ]





-- so, rather than doing the initialisation here, I think it needs to be in a function!

-- so the hell do we update the view? This might only work if main is here ??
-- htmlSignal = Signal.foldp update (init 0.0) mailbox.signal


-- ok so a HUGE problem here, is that we can't merge signals inside the
-- component. It has to be done in Main.elm!! So every component's cruft would
-- end up in main.elm
-- the problem is that there's just on e

-- createActionSignal : Signal Action
-- createActionSignal =
--   let
--     mailbox : Signal.Mailbox Action
--     mailbox = Signal.mailbox NoOp
--   in
--     Signal.mergeMany
--       [ Signal.map MouseMove MouseExtra.yVelocity
--       , Signal.map (\_ -> GlobalMouseUp) globalMouseUp
--       , mailbox.signal
--       ]

      -- To avoid overlaps, I think we want to only keep events when mouse is down
      -- We do still want to keep the mouse up and down events, because we
      -- might want to do something like change css in that case.


-- maybe we can use filterMap to filter out events we don't want (mouse move when mouse not down)
-- BUT, we must get the mouse down state from the model.
-- but we're not using model signal any more??? We don't even have access to the model signal,
-- because that is generated from above...
--    but if above passes this signal along maybe??
-- -- woah....


-- filterMap : (a -> Maybe b) -> b -> Signal a -> Signal b

-- modelSignal : Signal Model
-- modelSignal = Signal.foldp update init actionSignal

-- viewSignal : Signal Html
-- viewSignal = Signal.map (\model -> view model) modelSignal
--
-- main : Signal Html
-- main = viewSignal

-- next up we put two of these fuckers on one page!
