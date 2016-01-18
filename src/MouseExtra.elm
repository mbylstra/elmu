module MouseExtra
    ( velocity
    , xVelocity
    , yVelocity
    , onMouseMove
    ) where


import Json.Decode exposing (..)
import Html.Events exposing(on)
import Html exposing(Attribute)
import Mouse


type alias MousePosition = (Int, Int)


onMouseMove : Signal.Address MousePosition -> Attribute
onMouseMove mousePositionAddress =
  let
    mousePositionDecoder : Decoder MousePosition
    mousePositionDecoder =
      object2
        (\x y -> (x,y))
        ("pageX" := int)
        ("pageY" := int)

    sendPosition : MousePosition -> Signal.Message
    sendPosition position =
      Signal.message mousePositionAddress position

  in
    on "mousemove" mousePositionDecoder sendPosition


type alias VelocityState = {x : Int, velocity: Int}

createVelocitySignal : Signal Int -> Signal Int
createVelocitySignal positionSignal =
  let
    initialState = { x = 0, velocity = 0}

    update : Int -> VelocityState -> VelocityState
    update x state =
      { x = x
      , velocity = x - state.x
      }

    rawSignal : Signal VelocityState
    rawSignal =
      Signal.foldp update initialState positionSignal

    signal = Signal.map .velocity rawSignal

  in
    signal

xVelocity : Signal Int
xVelocity =
  createVelocitySignal Mouse.x

yVelocity : Signal Int
yVelocity =
  createVelocitySignal Mouse.y

velocity : Signal (Int, Int)
velocity =
  Signal.map2 (\x y -> (x, y)) xVelocity yVelocity
