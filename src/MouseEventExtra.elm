
-- import Json.Decode as Json
-- onClick : Signal.Address a -> Attribute
-- onClick address =
--     on "click" Json.value (\_ -> Signal.message address ())
import Json.Decode exposing (..)
import Html.Events exposing(on)
import Html exposing(Attribute)


type alias MousePosition = {x:Int, y:Int}


onMouseMove : Signal.Address MousePosition -> Attribute
onMouseMove mousePositionAddress =

  let
    sendPosition : MousePosition -> Signal.Message
    sendPosition position =
      Signal.message mousePositionAddress position
  in
    on "mousemove" mouseOffsetDecoder sendPosition


mouseOffsetDecoder : Decoder MousePosition
mouseOffsetDecoder =
  object2
    (\x y -> {x=x, y=y})
    ("offsetX" := int)
    ("offsetY" := int)
