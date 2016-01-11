module Piano (piano, pianoSignal) where

import Html exposing (..)
import Html.Attributes exposing(..)
import Html.Events exposing(onMouseDown)


pianoMailbox : Signal.Mailbox Float
pianoMailbox =  Signal.mailbox 60.0

pianoSignal : Signal Float
pianoSignal = pianoMailbox.signal


whiteKey pitch =
  li []
    [ div
      [ class "anchor", onMouseDown pianoMailbox.address pitch]
      []
    ]

whiteBlackKey pitch =
  li []
    [ div [class "anchor", onMouseDown pianoMailbox.address pitch] []
    , span [onMouseDown pianoMailbox.address (pitch - 1.0)] []
    ]

pianoOctave : Float -> List Html.Html
pianoOctave cPitch =
  [ whiteKey cPitch
  , whiteBlackKey (cPitch + 2.0)
  , whiteBlackKey (cPitch + 4.0)
  , whiteKey (cPitch + 5.0)
  , whiteBlackKey (cPitch + 7.0)
  , whiteBlackKey (cPitch + 9.0)
  , whiteBlackKey (cPitch + 11.0)
  ]

piano : Int -> Float -> Html.Html
piano numOctaves bottomPitch =
  let
    bottomPitches =
      List.map (\n -> bottomPitch + (toFloat n)*12.0) [1..numOctaves]
    pianoOctaves =
      List.concatMap (\octaveBottomPitch -> pianoOctave octaveBottomPitch ) bottomPitches
  in
    div [id "p-wrapper"]
      [ ul [id "piano"]
        pianoOctaves
      ]
