module Piano (piano, pianoSignal) where

import Html exposing (..)
import Html.Attributes exposing(..)
import Html.Events exposing(onMouseDown)


pianoMailbox : Signal.Mailbox Float
pianoMailbox =  Signal.mailbox 60.0

pianoSignal : Signal Float
pianoSignal = pianoMailbox.signal

whiteKey : Float -> Html
whiteKey pitch =
  div
    [ class "white-key", onMouseDown pianoMailbox.address pitch]
    []

whiteBlackKey : Float -> Html
whiteBlackKey pitch =
  div
    [ class "white-key"
    , onMouseDown pianoMailbox.address pitch
    ]
    [ div
      [ class "black-key"
      , onMouseDown pianoMailbox.address (pitch - 1.0)
      ]
      []
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
    div [class "piano"]
      pianoOctaves
