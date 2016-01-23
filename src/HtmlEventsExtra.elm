module HtmlEventsExtra where

import Html.Events exposing (on, onWithOptions, Options)
import Html exposing (Attribute)
import Json.Decode

messageOnWithOptions : String -> Options -> Signal.Address a -> a -> Attribute
messageOnWithOptions name options addr msg =
  onWithOptions name options Json.Decode.value (\_ -> Signal.message addr msg)

onMouseDownWithOptions : Options -> Signal.Address a -> a -> Attribute
onMouseDownWithOptions options =
  messageOnWithOptions "mousedown" options

preventDefault : Options
preventDefault =
  { stopPropagation = False
  , preventDefault = True
  }
