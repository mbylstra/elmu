module Slider where


import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Result exposing (withDefault)

import String


decodeSliderValue : String -> Float
decodeSliderValue result =
  ( result
    |> String.toFloat
    |> withDefault 0.0
  )
  -- |> (/) 100.0
  -- |> (/) 100.0


slider : Signal.Address Float -> Html
slider address =
  let
    eventHandler : Attribute
    eventHandler =
      on
        "input"
        targetValue
        ( \result ->
            Signal.message
              address
              (decodeSliderValue result)
        )
  in
    input
      [ type' "range"
      , Html.Attributes.min "0"
      , Html.Attributes.max "1"
      , Html.Attributes.step "0.001"
      , eventHandler
      ]
      []
